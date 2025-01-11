#!/bin/zsh

virtual_env_activate() {
  # check the current folder belong to earlier VIRTUAL_ENV folder, potentially deactivate.
  if [[ -n "$VIRTUAL_ENV" ]]; then
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]]; then
      command -v deactivate >/dev/null 2>&1 && deactivate
    fi
  fi

  # if .python-version is found, create/show .venv
  if [ -f .python-version ] && [ ! -d ./.venv ]; then
    uv venv
  fi

  # if .venv is found and not activated, activate it
  if [[ -z "$VIRTUAL_ENV" ]]; then
    # if .venv folder is found then activate the vitualenv
    if [ -d ./.venv ] && [ -f ./.venv/bin/activate ]; then
      source ./.venv/bin/activate
    fi
fi
}

# Function to change directory using pushd and popd
change_directory() {
    if [[ -z "$1" ]]; then
        # No argument provided, change to home directory
        pushd ~ > /dev/null
    elif [[ "$1" == "--" ]]; then
        # Argument is '--', execute the specified command
        pushd $(python ~/engine-room/dotfiles/zsh/bin/cd.py $(dirs -v)) > /dev/null
    else
        # Change to the directory specified in the argument
        pushd "$1" > /dev/null
    fi
}

# Call the function with the first argument
change_directory "$1"
virtual_env_activate
