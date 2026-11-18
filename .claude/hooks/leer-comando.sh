#!/usr/bin/env bash
# Común a los hooks PreToolUse de los agentes: lee de la entrada estándar el
# JSON de la llamada y deja en $comando el valor de tool_input.command, ya
# descodificado. Quien lo incluye define antes la función bloquear().

leer_comando() {
  local entrada marca
  entrada=$(cat)

  # Extrae tool_input.command sin depender de jq.
  comando=$(printf '%s' "$entrada" | tr '\n' ' ' \
    | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"((\\.|[^"\\])*)".*/\1/p')
  [ -n "$comando" ] || bloquear "no se pudo leer el comando"

  # Descodifica los escapes de JSON. La barra invertida literal (\\) se
  # aparta primero para no confundir una ruta de Windows (C:\\new, C:\\users)
  # con un salto de línea (\n) o un escape Unicode (\u).
  marca=$(printf '\001')
  comando=$(printf '%s' "$comando" | sed -e "s/\\\\\\\\/$marca/g")
  case "$comando" in
    *'\n'* | *'\r'*) bloquear "no se admiten comandos de varias líneas" ;;
    # Un escape \uXXXX podría ocultar ;, & o >: no se descodifica, se bloquea.
    *'\u'*) bloquear "el comando contiene escapes que no se pueden comprobar" ;;
  esac
  comando=$(printf '%s' "$comando" \
    | sed -e 's/\\"/"/g' -e 's/\\\//\//g' -e 's/\\t/ /g' -e "s/$marca/\\\\/g")
}
