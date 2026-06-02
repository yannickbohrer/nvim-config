#!/usr/bin/env bash
set -euo pipefail

greet() {
    local name="$1"
    echo "Hello, ${name}!"
}

main() {
    local animals=("Rex" "Buddy" "Max")
    for animal in "${animals[@]}"; do
        greet "${animal}"
    done
}

main "$@"
