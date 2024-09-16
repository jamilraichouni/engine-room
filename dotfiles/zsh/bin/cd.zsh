#!/bin/zsh

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

