#!/usr/bin/env bash
# Assigns @tab-color window option based on window name patterns.
# Called by tmux hooks on window rename/create.

update_window_color() {
  local wid="$1"
  local name
  name=$(tmux display-message -t "$wid" -p '#W' 2>/dev/null) || return
  # lowercase for case-insensitive matching on ASCII part
  local lname=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  local color="default"

  case "$lname" in
    *python*|*srun*|*bash*|*zsh*) color="yellow" ;;
    *gitui*)         color="magenta" ;;
    *yazi*)          color="blue" ;;
    *claude*|*cursor*) color="red" ;;
    *vim*)           color="green" ;;
  esac

  # Also check for nerd font symbols (case doesn't apply)
  if [ "$color" = "default" ]; then
    case "$name" in
      **|*󰔬*|**|**)
        color="yellow" ;;
      *󰹑*|*󰒔*|**|**|*󱂅*|*󰞍*)
        color="magenta" ;;
      *󰙅*|**|*󱕍*|*󰒗*)
        color="blue" ;;
      **|*󰭻*)
        color="red" ;;
      **)
        color="green" ;;
    esac
  fi

  tmux set-option -wqt "$wid" @tab-color "$color"
}

# If called with "all", update every window; otherwise update the given window
if [ "$1" = "all" ]; then
  for wid in $(tmux list-windows -a -F '#{window_id}' 2>/dev/null); do
    update_window_color "$wid"
  done
else
  update_window_color "${1:-$(tmux display-message -p '#{window_id}')}"
fi
