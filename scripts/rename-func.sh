#! /usr/bin/env bash

# usage: rename-func.sh path-to-export-symbol-source

ROOT_DIR=$(dirname $(dirname $(realpath $0)))
SRC_DIR=$(realpath $1)
TARGET_DIR="${ROOT_DIR}/src"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target source directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

EXPORT_LINES=$(find "$TARGET_DIR" -type f \( -name '*.c' -o -name '*.h' \) \
    -exec grep -hEo 'EXPORT_SYMBOL\(max9[A-Za-z0-9_]+\);' {} +) || GREP_STATUS=$?

if [ "${GREP_STATUS:-0}" -gt 1 ]; then
    echo "Error: failed to search for exported functions in $TARGET_DIR" >&2
    exit "$GREP_STATUS"
fi

EXPORTED_FUNCS=$(printf '%s\n' "$EXPORT_LINES" |
    sed -E 's/EXPORT_SYMBOL\((max9[A-Za-z0-9_]+)\);/\1/' |
    sort -u)

if [ -z "$EXPORTED_FUNCS" ]; then
    echo "Error: no EXPORT_SYMBOL(max9...) functions found in $TARGET_DIR" >&2
    exit 1
fi

printf 'Renaming exported functions in %s:\n' "$TARGET_DIR"
while IFS= read -r func; do
    [ -n "$func" ] || continue
    printf '  %s -> rs_%s\n' "$func" "$func"
    find "$TARGET_DIR" -type f \( -name '*.c' -o -name '*.h' \) \
        -exec sed -i '' -E \
        -e ':a' \
        -e "s#(^|[^[:alnum:]_])${func}([^[:alnum:]_]|$)#\\1rs_${func}\\2#g" \
        -e 'ta' {} +
done <<EOF
$EXPORTED_FUNCS
EOF
