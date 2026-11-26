#! /usr/bin/env bash

ROOT_DIR=$(dirname $(dirname $(realpath $0)))
SRC_DIR=$(realpath $1)

find ${ROOT_DIR}/src -type f \( -name '*.c' -o -name '*.h' \) -exec sed -i '' -E 's|<(media/max9[0-9]+\.h)>|"\1"|g' {} +
