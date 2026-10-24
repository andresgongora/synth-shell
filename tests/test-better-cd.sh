#!/usr/bin/env bash
# Modified 2026-10-24: regression for forwarding directory arguments.
set -e
script_dir=$(builtin cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../synth-shell/better-cd.sh"
fixture=$1
better_cd "$fixture/directory with spaces"
[[ "$PWD" == "$fixture/directory with spaces" ]]
better_cd "$fixture/plain"
[[ "$PWD" == "$fixture/plain" ]]
printf '%s\n' 'PASS: space-containing and ordinary directory arguments'
