#!/usr/bin/env sh
set -eu

company="${1:-schunk}"
source_root="excel-to-aasx/data/generated/${company}/xlsx-json-step4"
target_root="aas"

if [ ! -d "$source_root" ]; then
  echo "missing generated output: $source_root" >&2
  echo "run: cd excel-to-aasx && make generate COMPANY=${company}" >&2
  exit 2
fi

mkdir -p "$target_root"

tmp_list="$(mktemp)"
find "$source_root" -type f -name '*.aasx' > "$tmp_list"

if [ ! -s "$tmp_list" ]; then
  rm -f "$tmp_list"
  echo "no .aasx files found under $source_root" >&2
  exit 3
fi

while IFS= read -r aasx; do
  cp "$aasx" "$target_root/"
  echo "copied $aasx -> $target_root/"
done < "$tmp_list"

rm -f "$tmp_list"
