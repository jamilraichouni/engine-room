#!/bin/env zsh
# kitty +kitten ssh "$@" when env var KITTY_PID exists and $TERM is xterm-kitty
# otherwise, run ssh "$@"

if [[ -n $KITTY_PID && $TERM == xterm-kitty ]]; then
  kitty +kitten ssh "$@"
else
  /usr/bin/ssh "$@"
fi
