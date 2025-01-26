#!/bin/sh
echo -ne '\033c\033]0;GGJ 2025\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/PuggleStruggle-Linux.x86_64" "$@"
