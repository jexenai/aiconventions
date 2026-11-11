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
# Descodifica los escapes de JSON. La barra invertida literal (\\) se aparta
# primero para no confundir una ruta de Windows (C:\\new, C:\\users) con un
# salto de línea (\n) o un escape Unicode (\u).
marca=$(printf '\001')
comando=$(printf '%s' "$comando" | sed -e "s/\\\\\\\\/$marca/g")
case "$comando" in
  *'\n'* | *'\r'*) bloquear "no se admiten comandos de varias líneas" ;;
  # Un escape \uXXXX podría ocultar ;, & o >: no se descodifica, se bloquea.
  *'\u'*) bloquear "el comando contiene escapes que no se pueden comprobar" ;;
esac
comando=$(printf '%s' "$comando" \
  | sed -e 's/\\"/"/g' -e 's/\\\//\//g' -e 's/\\t/ /g' -e "s/$marca/\\\\/g")

# Sin encadenar, redirigir ni sustituir: un único comando simple.
case "$comando" in
  *';'* | *'&'* | *'|'* | *'>'* | *'<'* | *'`'* | *'$'*)
    bloquear "no se admiten ;, &, |, redirecciones ni sustituciones" ;;
esac

# Opciones que escriben ficheros, corrigen código o ejecutan código externo.
case " $comando " in
  *' --fix'* | *' --output'* | *' --ext-diff'* | *' --init-script'* | *' -I '* | \
  *' --repair'* | *' --generate-baseline'* | *' --cache'*)
    bloquear "la opción escribe ficheros o ejecuta código externo" ;;
esac

# Formas equivalentes de lanzar los binarios de Composer.
case "$comando" in
  "php vendor/bin/"*) comando=${comando#php } ;;
  "php ./vendor/bin/"*) comando=${comando#php ./} ;;
  "./vendor/bin/"*) comando=${comando#./} ;;
esac

set -f
# shellcheck disable=SC2086
set -- $comando
programa=$1
shift

# Bloquea el comando si lleva alguno de los argumentos indicados.
sin_argumentos() {
  prohibidos=$1
  shift
  for argumento in "$@"; do
    case " $prohibidos " in
      *" $argumento "*) bloquear "'$argumento' escribe ficheros" ;;
    esac
  done
}

# npx solo ejecuta lo ya instalado: sin --no-install descargaría y
# ejecutaría el paquete si falta en node_modules.
npx_instalado() {
  [ -e "node_modules/.bin/$1" ] ||
    bloquear "'$1' no está instalado en node_modules y npx lo descargaría; usa npx --no-install"
}

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
  npx)
    sin_descarga=""
    if [ "$1" = "--no-install" ]; then sin_descarga=1; shift; fi
    herramienta=$1
    [ $# -gt 0 ] && shift
    case "$herramienta" in
      eslint)
        [ $# -gt 0 ] || bloquear "falta la ruta que analiza ESLint"
        for argumento in "$@"; do
          case "$argumento" in
            -o* | --init) bloquear "'$argumento' escribe ficheros" ;;
          esac
        done ;;
      tsc)
        # Solo comprobación de tipos: cualquier otra opción puede emitir
        # ficheros (--incremental, --tsBuildInfoFile, --build, --outDir…).
        [ "$1" = "--noEmit" ] || bloquear "tsc solo se admite con --noEmit"
        shift
        saltar=""
        for argumento in "$@"; do
          if [ -n "$saltar" ]; then saltar=""; continue; fi
          case "$argumento" in
            -p | --project) saltar=1 ;;
            --pretty | --skipLibCheck) ;;
            *) bloquear "'$argumento' no es una opción permitida de tsc" ;;
          esac
        done ;;
      *) bloquear "solo se permiten eslint y tsc con npx" ;;
    esac
    [ -n "$sin_descarga" ] || npx_instalado "$herramienta"
    exit 0 ;;
  npm)
    case "$1" in
      audit)
        shift
        sin_argumentos "fix" "$@"
        exit 0 ;;
      run)
        # Scripts de comprobación de las plantillas de stack y de
        # setup-testing. Lo que ejecutan lo define package.json.
        case "$2" in
          lint | typecheck | check | types:check | format:check) exit 0 ;;
        esac ;;
    esac ;;
  composer)
    case "$1" in
      validate | audit | lint:check | types:check) exit 0 ;;
    esac ;;
esac

case "$comando" in
  "vendor/bin/pint --test" | "vendor/bin/pint --test "*)
    exit 0 ;;
  "vendor/bin/phpstan analyse" | "vendor/bin/phpstan analyse "*)
    sin_argumentos "-b" "$@"
    exit 0 ;;
esac

bloquear "el comando no está en la lista de comprobaciones de solo lectura"
