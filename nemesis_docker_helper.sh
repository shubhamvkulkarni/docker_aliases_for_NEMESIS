#!/usr/bin/env bash
# Shared by the csh/tcsh aliases, which do not support shell functions.
set -euo pipefail

mode="$1"
shift
executable="$1"
shift

image_name="${NEMESIS_DOCKER_IMAGE:-patrickirwinoxford/docker_nemesis}"
calculation_directory="$(pwd)"

if [[ "$mode" == --standard ]]; then
  exec docker run --rm -i -v "$calculation_directory":/data -w /data \
    "$image_name" "$executable" "$@"
fi

docker_arguments=(--rm -i -v "$calculation_directory:/data" -w /data)
list_files=()
for candidate in "$calculation_directory"/*.kls "$calculation_directory"/*.lls; do
  [[ -e "$candidate" ]] || continue
  case "$(basename "$candidate")" in
    intrad.kls|intrad.lls) ;;
    *) list_files+=("$candidate") ;;
  esac
done

if (( ${#list_files[@]} > 1 )); then
  printf 'Error: found more than one .kls/.lls file in %s\n' "$calculation_directory" >&2
  printf '       %s\n' "${list_files[*]}" >&2
  exit 2
fi

mounted_directories=()
if (( ${#list_files[@]} == 1 )); then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* || "$line" != /* ]] && continue

    external_directory="$(dirname "$line")"
    if [[ ! -e "$line" ]]; then
      printf 'Error: external file does not exist on the host:\n       %s\n' "$line" >&2
      exit 2
    fi
    already_mounted=0
    for mounted_directory in "${mounted_directories[@]-}"; do
      if [[ "$mounted_directory" == "$external_directory" ]]; then
        already_mounted=1
        break
      fi
    done
    if (( already_mounted == 0 )); then
      printf 'Mounting external data directory: %s\n' "$external_directory" >&2
      docker_arguments+=(--mount "type=bind,source=$external_directory,target=$external_directory,readonly")
      mounted_directories+=("$external_directory")
    fi
  done < "${list_files[0]}"
fi

exec docker run "${docker_arguments[@]}" "$image_name" "$executable" "$@"
