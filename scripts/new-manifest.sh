#!/usr/bin/env bash
set -euo pipefail

root_path=""
output_path="dist/manifest.json"
archive_path="dist/aiconventions.zip"
template_version=""
tracked_only="false"
default_exclude_paths=(".github" "scripts" ".gitattributes" "README.md" "pila_tecnologica.md" ".agents" ".codex" "AGENTS.md")
exclude_paths=()

usage() {
  cat <<'USAGE'
Uso:
  scripts/new-manifest.sh [opciones]

Opciones:
  --root PATH                 Raiz del repositorio. Por defecto, la carpeta padre de scripts/.
  --output PATH               Ruta del manifest. Por defecto: dist/manifest.json.
  --archive PATH              Ruta del zip. Por defecto: dist/aiconventions.zip.
  --template-version VERSION  Version de la plantilla, por ejemplo 2026.09.29.
  --tracked-only              Incluye solo archivos versionados en Git.
  --exclude PATH              Excluye un archivo o carpeta del manifest. Repetible.
                              Por defecto, si no se indica, excluye .github, scripts,
                              .gitattributes, README.md, pila_tecnologica.md,
                              .agents, .codex y AGENTS.md.
  -h, --help                  Muestra esta ayuda.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      root_path="${2:?Falta valor para --root}"
      shift 2
      ;;
    --output)
      output_path="${2:?Falta valor para --output}"
      shift 2
      ;;
    --archive)
      archive_path="${2:?Falta valor para --archive}"
      shift 2
      ;;
    --template-version)
      template_version="${2:?Falta valor para --template-version}"
      shift 2
      ;;
    --tracked-only)
      tracked_only="true"
      shift
      ;;
    --exclude)
      exclude_paths+=("${2:?Falta valor para --exclude}")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opcion no reconocida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "No se encontro '$command_name' en PATH." >&2
    exit 1
  fi
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\b'/\\b}"
  value="${value//$'\f'/\\f}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

json_string() {
  printf '"%s"' "$(json_escape "$1")"
}

absolute_path() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  cd "$(dirname "$path")" && printf '%s/%s\n' "$(pwd -P)" "$(basename "$path")"
}

resolve_path() {
  local base="$1"
  local path="$2"

  if [[ "$path" = /* || "$path" =~ ^[A-Za-z]:[/\\] ]]; then
    absolute_path "$path"
  else
    absolute_path "$base/$path"
  fi
}

relative_path() {
  local base="$1"
  local path="$2"
  local relative

  relative="$(realpath --relative-to="$base" "$path")"
  printf '%s\n' "$relative" | tr '\\' '/'
}

normalize_manifest_path() {
  local path="$1"

  path="${path//\\//}"
  path="${path#./}"
  path="${path%/}"
  printf '%s\n' "$path"
}

normalize_exclude_path() {
  local base="$1"
  local path="$2"
  local relative

  if [[ "$path" = /* || "$path" =~ ^[A-Za-z]:[/\\] ]]; then
    relative="$(realpath -m --relative-to="$base" "$path")"
    normalize_manifest_path "$relative"
  else
    normalize_manifest_path "$path"
  fi
}

file_size() {
  stat -c '%s' "$1"
}

file_modified_at() {
  local epoch
  epoch="$(stat -c '%Y' "$1")"
  date -u -d "@$epoch" '+%Y-%m-%dT%H:%M:%SZ'
}

sha256_hex() {
  sha256sum "$1" | awk '{ print tolower($1) }'
}

create_zip() {
  local archive="$1"
  local list_file="$2"

  rm -f "$archive"

  if command -v zip >/dev/null 2>&1; then
    zip -q -X -@ "$archive" < "$list_file"
    return
  fi

  echo "No se pudo crear el zip. Instala 'zip' en Git Bash y vuelve a ejecutar el script." >&2
  exit 1
}

require_command git
require_command sha256sum
require_command stat
require_command date
require_command sort
require_command awk
require_command realpath

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ -z "$root_path" ]]; then
  root_path="$(cd -- "$script_dir/.." && pwd -P)"
else
  root_path="$(cd -- "$root_path" && pwd -P)"
fi

output_abs="$(resolve_path "$root_path" "$output_path")"
archive_abs="$(resolve_path "$root_path" "$archive_path")"
output_relative="$(relative_path "$root_path" "$output_abs")"
archive_relative="$(relative_path "$root_path" "$archive_abs")"

mkdir -p "$(dirname "$output_abs")" "$(dirname "$archive_abs")"

files_tmp="$(mktemp)"
excludes_tmp="$(mktemp)"
sorted_files_tmp="$(mktemp)"
trap 'rm -f "$files_tmp" "$excludes_tmp" "$sorted_files_tmp"' EXIT

if [[ "${#exclude_paths[@]}" -eq 0 ]]; then
  exclude_paths=("${default_exclude_paths[@]}")
fi

for exclude_path in "${exclude_paths[@]}"; do
  normalized_exclude="$(normalize_exclude_path "$root_path" "$exclude_path")"
  [[ -n "$normalized_exclude" && "$normalized_exclude" != "." ]] || continue
  printf '%s\n' "$normalized_exclude" >> "$excludes_tmp"
done

if git -C "$root_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$root_path" ls-files -z | tr '\0' '\n' > "$files_tmp"

  if [[ "$tracked_only" != "true" ]]; then
    git -C "$root_path" ls-files --others --exclude-standard -z | tr '\0' '\n' >> "$files_tmp"
  fi
else
  (
    cd "$root_path"
    find . \
      -path './.git' -prune -o \
      -path './dist' -prune -o \
      -type f -print |
      sed 's#^\./##'
  ) > "$files_tmp"
fi

awk -v output="$output_relative" -v archive="$archive_relative" -v excludes="$excludes_tmp" '
  BEGIN {
    while ((getline exclude < excludes) > 0) {
      excludes_count += 1
      excluded_paths[excludes_count] = exclude
    }
  }

  function is_excluded(path, i, prefix) {
    for (i = 1; i <= excludes_count; i += 1) {
      prefix = excluded_paths[i] "/"
      if (path == excluded_paths[i] || index(path, prefix) == 1) {
        return 1
      }
    }
    return 0
  }

  NF > 0 && $0 != output && $0 != archive && $0 !~ /^dist\// && !is_excluded($0) { print }
' "$files_tmp" |
  sort -u > "$sorted_files_tmp"

(
  cd "$root_path"
  create_zip "$archive_abs" "$sorted_files_tmp"
)

archive_hash="$(sha256_hex "$archive_abs")"
archive_size="$(file_size "$archive_abs")"
generated_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

{
  printf '{\n'
  printf '  "schema": "aiconventions.manifest.v1",\n'
  printf '  "generatedAt": %s,\n' "$(json_string "$generated_at")"

  if [[ -n "$template_version" ]]; then
    printf '  "templateVersion": %s,\n' "$(json_string "$template_version")"
  else
    printf '  "templateVersion": null,\n'
  fi

  printf '  "hashAlgorithm": "sha256",\n'
  printf '  "archive": {\n'
  printf '    "path": %s,\n' "$(json_string "$archive_relative")"
  printf '    "hash": %s,\n' "$(json_string "sha256:$archive_hash")"
  printf '    "sizeBytes": %s\n' "$archive_size"
  printf '  },\n'
  printf '  "files": [\n'

  first="true"
  while IFS= read -r relative_file; do
    full_path="$root_path/$relative_file"
    [[ -f "$full_path" ]] || continue

    if [[ "$first" == "true" ]]; then
      first="false"
    else
      printf ',\n'
    fi

    file_hash="$(sha256_hex "$full_path")"
    size_bytes="$(file_size "$full_path")"
    modified_at="$(file_modified_at "$full_path")"

    printf '    {\n'
    printf '      "path": %s,\n' "$(json_string "$relative_file")"
    printf '      "source": %s,\n' "$(json_string "$relative_file")"
    printf '      "hash": %s,\n' "$(json_string "sha256:$file_hash")"
    printf '      "sizeBytes": %s,\n' "$size_bytes"
    printf '      "modifiedAt": %s,\n' "$(json_string "$modified_at")"
    printf '      "mode": "managed",\n'
    printf '      "strategy": "replace"\n'
    printf '    }'
  done < "$sorted_files_tmp"

  printf '\n'
  printf '  ]\n'
  printf '}\n'
} > "$output_abs"

file_count="$(wc -l < "$sorted_files_tmp" | awk '{ print $1 }')"
echo "Manifest generado en $output_abs con $file_count archivos."
echo "Zip generado en $archive_abs."
