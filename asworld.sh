#!/bin/sh
echo -ne '\033c\033]0;asworld\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/asworld.x86_64" "$@"
