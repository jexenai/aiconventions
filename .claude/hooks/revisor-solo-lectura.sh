#!/usr/bin/env bash
# Hook PreToolUse de los revisores (.claude/agents/*-reviewer.md).
# Solo deja pasar lecturas de Git y comprobaciones estáticas que no
# modifican el repositorio ni la base de datos. Todo lo demás, incluidas las
# pruebas, se bloquea: las ejecuta la conversación principal y pasa el
# resultado al revisor. Si no reconoce el comando, lo bloquea.

bloquear() {
  echo "Bloqueado por el hook de los revisores: $1. Anótalo en el informe como comprobación no ejecutada y no busques otra forma de ejecutarlo." >&2
  exit 2
}

entrada=$(cat)

# Extrae tool_input.command sin depender de jq.
comando=$(printf '%s' "$entrada" | tr '\n' ' ' \
  | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"((\\.|[^"\\])*)".*/\1/p')
[ -n "$comando" ] || bloquear "no se pudo leer el comando"
# Un escape \uXXXX podría ocultar ;, & o >: no se descodifica, se bloquea.
case "$comando" in
  *'\u'*) bloquear "el comando contiene escapes que no se pueden comprobar" ;;
esac
comando=$(printf '%s' "$comando" | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g')

# Sin encadenar, redirigir ni sustituir: un único comando simple.
case "$comando" in
  *';'* | *'&'* | *'|'* | *'>'* | *'<'* | *'`'* | *'$'* | *'\n'*)
    bloquear "no se admiten ;, &, |, redirecciones ni sustituciones" ;;
esac

# Opciones que escriben ficheros, corrigen código o ejecutan código externo.
case " $comando " in
  *' --fix'* | *' --output'* | *' --ext-diff'* | *' --init-script'* | *' -I '*)
    bloquear "la opción escribe ficheros o ejecuta código externo" ;;
esac

set -f
# shellcheck disable=SC2086
set -- $comando
programa=$1
shift

# Maven y Gradle: solo compilación y comprobaciones, nunca pruebas.
objetivos_permitidos() {
  permitidos=$1
  shift
  saltar=""
  for argumento in "$@"; do
    if [ -n "$saltar" ]; then saltar=""; continue; fi
    case "$argumento" in
      -f | --file | -pl | --projects | -P | -s | --settings | -p | --project-dir | -x | --exclude-task)
        saltar=1 ;;
      -*) ;;
      *)
        case " $permitidos " in
          *" $argumento "*) ;;
          *) bloquear "'$argumento' no es una tarea permitida" ;;
        esac ;;
    esac
  done
}

case "$programa" in
  git)
    case "$1" in
      status | diff | log | show | merge-base | rev-parse | ls-files | blame) exit 0 ;;
      *) bloquear "solo se permiten lecturas de Git" ;;
    esac ;;
  mvn | ./mvnw | mvnw)
    [ $# -gt 0 ] || bloquear "falta el objetivo de Maven"
    objetivos_permitidos "validate compile test-compile checkstyle:check spotless:check dependency-check:check org.owasp:dependency-check-maven:check" "$@"
    exit 0 ;;
  ./gradlew | gradlew | gradle)
    [ $# -gt 0 ] || bloquear "falta la tarea de Gradle"
    objetivos_permitidos "compileJava compileTestJava checkstyleMain checkstyleTest spotlessCheck dependencyCheckAnalyze" "$@"
    exit 0 ;;
esac

case "$comando" in
  "vendor/bin/pint --test" | "vendor/bin/pint --test "* | \
  "vendor/bin/phpstan analyse" | "vendor/bin/phpstan analyse "* | \
  "composer validate" | "composer validate "* | \
  "composer audit" | "composer audit "* | \
  "npm run lint" | "npm run lint "* | \
  "npm run typecheck" | "npm run typecheck "* | \
  "npm audit" | "npm audit "* | \
  "npx tsc --noEmit" | "npx tsc --noEmit "* | \
  "npx eslint "*)
    exit 0 ;;
esac

bloquear "el comando no está en la lista de comprobaciones de solo lectura"
