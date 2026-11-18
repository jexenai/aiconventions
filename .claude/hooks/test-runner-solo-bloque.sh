#!/usr/bin/env bash
# Hook PreToolUse de test-runner (.claude/agents/test-runner.md).
# Solo deja pasar los comandos del bloque que el setup genera en ese mismo
# fichero, entre las marcas comandos-test-runner. Cualquier otro comando se
# bloquea, también los de las filas marcadas «no ejecutar».

bloquear() {
  echo "Bloqueado por el hook de test-runner: $1. Informa esa fila como «no ejecutado (bloqueado por el hook)» y no busques otra forma de ejecutarlo." >&2
  exit 2
}

# shellcheck source=leer-comando.sh
. "$(dirname "$0")/leer-comando.sh"
leer_comando

agente="$(dirname "$0")/../agents/test-runner.md"
[ -f "$agente" ] || bloquear "no se encuentra $agente"

# Las dos funciones dejan el resultado en $R en lugar de imprimirlo: en
# Windows cada subproceso cuesta décimas de segundo y el hook se ejecuta en
# cada comando.

# Quita espacios de los extremos y junta los repetidos.
normalizar() {
  local IFS=$' \t\r\n'
  set -f
  # shellcheck disable=SC2086
  set -- $1
  set +f
  IFS=' '
  R="$*"
}

# Quita las comillas inversas con las que una celda puede venir escrita.
sin_formato() {
  normalizar "$1"
  R=${R#\`}
  R=${R%\`}
}

# ¿Coincide $1 con el comando de la fila $2? {prueba} admite el nombre o la
# ruta de una prueba: sin espacios, comillas ni caracteres de la shell.
coincide() {
  local recibido=$1 fila=$2 antes despues medio
  case "$fila" in
    *'{prueba}'*)
      antes=${fila%%\{prueba\}*}
      despues=${fila#*\{prueba\}}
      case "$recibido" in
        "$antes"*"$despues") ;;
        *) return 1 ;;
      esac
      medio=${recibido#"$antes"}
      medio=${medio%"$despues"}
      [[ "$medio" =~ ^[A-Za-z0-9_./:\\#@,=*-]+$ ]] ;;
    *) [ "$recibido" = "$fila" ] ;;
  esac
}

normalizar "$comando"
recibido=$R
dentro=""
vetada=""

while IFS= read -r linea; do
  case "$linea" in
    *'comandos-test-runner:inicio'*) dentro=1; continue ;;
    *'comandos-test-runner:fin'*) break ;;
  esac
  [ -n "$dentro" ] || continue
  case "$linea" in
    '|'*) ;;
    *) continue ;;
  esac

  # Columnas: Alcance | Parte | Comando | Directorio | Incluye | Condición.
  IFS='|' read -r _ _ _ c_comando c_directorio _ c_condicion _ <<EOF
$linea
EOF
  sin_formato "$c_comando"
  fila=$R
  sin_formato "$c_directorio"
  directorio=$R
  normalizar "$c_condicion"
  condicion=$R

  case "$fila" in
    '' | '—' | '-' | Comando | -*-) continue ;;
  esac

  # Formas admitidas: el comando tal cual o precedido del cambio a su
  # directorio (&& en Bash, ; en PowerShell).
  encaja=""
  if coincide "$recibido" "$fila"; then
    encaja=1
  else
    case "$directorio" in
      '' | '—' | '-' | '.') ;;
      *)
        for prefijo in "cd $directorio && " "cd $directorio; " \
          "cd \"$directorio\" && " "cd \"$directorio\"; "; do
          case "$recibido" in
            "$prefijo"*)
              if coincide "${recibido#"$prefijo"}" "$fila"; then encaja=1; fi ;;
          esac
        done ;;
    esac
  fi
  [ -n "$encaja" ] || continue

  case "$condicion" in
    'no ejecutar'* | 'no aplica'*) vetada=$condicion ;;
    *) exit 0 ;;
  esac
done < "$agente"

[ -z "$vetada" ] || bloquear "la fila de ese comando está marcada «$vetada»"
bloquear "el comando no coincide con ninguna fila del bloque de comandos"
