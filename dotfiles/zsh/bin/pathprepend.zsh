#!/bin/env zsh
if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
  PATH="$1:${PATH:+"$PATH"}"
fi