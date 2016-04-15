#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HELPERS_DIR="$CURRENT_DIR"

source "$HELPERS_DIR/helpers.sh"

main() {
    tmux send-keys -l "$($(clipboard_paste_command))"
}

main
