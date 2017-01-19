#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$CURRENT_DIR/scripts"
HELPERS_DIR="$CURRENT_DIR/scripts"

source "$HELPERS_DIR/helpers.sh"

clipboard_copy_without_newline_command() {
	local copy_command="$1"
	echo "tr -d '\n' | $copy_command"
}

set_error_bindings() {
	local key_bindings="$(yank_key) $(put_key) $(yank_put_key)"
	local key
	for key in $key_bindings; do
		tmux bind-key -T copy-mode-vi "$key" send-keys -X copy-pipe "tmux display-message 'Error! tmux-yank dependencies not installed!'"
		tmux bind-key -T copy-mode    "$key" send-keys -X copy-pipe "tmux display-message 'Error! tmux-yank dependencies not installed!'"
	done
}

error_handling_if_command_not_present() {
	local copy_command="$1"
	if [ -z "$copy_command" ]; then
		set_error_bindings
		exit 0
	fi
}

# `yank_without_newline` binding isn't intended to be used by the user. It is
# a helper for `copy_line` command.
set_copy_mode_bindings() {
	local copy_command="$1"
	local copy_wo_newline_command="$(clipboard_copy_without_newline_command "$copy_command")"
	#tmux bind-key -t vi-copy "$(yank_key)"     copy-pipe "$copy_command"
	tmux bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "$copy_command"
	tmux bind-key -T copy-mode-vi "$(put_key)"      send-keys -X copy-pipe "tmux paste-buffer"
	tmux bind-key -T copy-mode-vi "$(yank_put_key)" send-keys -X copy-pipe "$copy_command; tmux paste-buffer"
	tmux bind-key -T copy-mode-vi "$(yank_wo_newline_key)" send-keys -X copy-pipe "$copy_wo_newline_command"

	#tmux bind-key -t emacs-copy "$(yank_key)"     copy-pipe "$copy_command"
	tmux bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "$copy_command"
	tmux bind-key -T copy-mode "$(put_key)"      send-keys -X copy-pipe "tmux paste-buffer"
	tmux bind-key -T copy-mode "$(yank_put_key)" send-keys -X copy-pipe "$copy_command; tmux paste-buffer"
	tmux bind-key -T copy-mode "$(yank_wo_newline_key)" send-keys -X copy-pipe "$copy_wo_newline_command"

	tmux bind-key -T root MouseDown2Pane run-shell "$SCRIPTS_DIR/paste_pane.sh"
}

set_normal_bindings() {
	tmux bind-key "$(yank_line_key)" run-shell "$SCRIPTS_DIR/copy_line.sh"
	tmux bind-key "$(yank_pane_pwd_key)" run-shell "$SCRIPTS_DIR/copy_pane_pwd.sh"
}

main() {
	local copy_command="$(clipboard_copy_command)"
	error_handling_if_command_not_present "$copy_command"
	set_copy_mode_bindings "$copy_command"
	set_normal_bindings
}
main
