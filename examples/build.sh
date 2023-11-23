#!/usr/bin/env bash

NAME="$1"

if [[ ! -f "${NAME}.jai" ]]; then
    echo "Example '$NAME' doesn't exist."
    exit 1
fi

set -xe

mkdir -p bin
jai "${NAME}.jai" -output_path bin/ -quiet

{ set +x; } &> /dev/null

if [[ "$2" == "run" ]]; then
    echo "==== RUNNING ===="
    "bin/${NAME}"
fi
