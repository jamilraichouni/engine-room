#!/bin/zsh

unset -f pydoc > /dev/null 2>&1 || true
if ! [ -z "${_OLD_VIRTUAL_PATH:+_}" ]
then
        PATH="$_OLD_VIRTUAL_PATH" 
        export PATH
        unset _OLD_VIRTUAL_PATH
fi
if ! [ -z "${_OLD_VIRTUAL_PYTHONHOME+_}" ]
then
        PYTHONHOME="$_OLD_VIRTUAL_PYTHONHOME" 
        export PYTHONHOME
        unset _OLD_VIRTUAL_PYTHONHOME
fi
hash -r 2> /dev/null
if ! [ -z "${_OLD_VIRTUAL_PS1+_}" ]
then
        PS1="$_OLD_VIRTUAL_PS1" 
        export PS1
        unset _OLD_VIRTUAL_PS1
fi
unset VIRTUAL_ENV
unset VIRTUAL_ENV_PROMPT
