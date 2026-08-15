. $DOT/zsh/key-bindings.zsh

# aliases MUST be sourced after oh-my-zsh !!!
unalias -a && [[ -f $DOT/zsh/aliases.zsh ]] && . $DOT/zsh/aliases.zsh

# fzf
source <(fzf --zsh)

# load custom functions
. $DOT/zsh/funcs.zsh

function __set_starship_python_venv_parent() {
  if [[ -n ${VIRTUAL_ENV:-} ]]; then
    export STARSHIP_PYTHON_VENV_PARENT=${VIRTUAL_ENV:h:t}
  else
    unset STARSHIP_PYTHON_VENV_PARENT
  fi
}

# venv handling with `cd` command
function __python_venv_on_cd() {
  setopt local_options err_return

  if [[ -n ${VIRTUAL_ENV:-} ]] && [[ $PWD != ${VIRTUAL_ENV%/*}/* ]]; then
    deactivate > /dev/null 2>&1 || unset VIRTUAL_ENV
  fi

  if [[ -f .venv/bin/activate ]]; then
    . .venv/bin/activate
  elif [[ -f /opt/.venv/bin/activate ]]; then
    . /opt/.venv/bin/activate
  fi
  __set_starship_python_venv_parent
  if whence -p starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi
}

chpwd_functions+=(__python_venv_on_cd)

# when a terminal starts (especially in nvim), activate venv if .venv exists
# or fall back to /opt/.venv if it exists
if [[ -f .venv/bin/activate ]]; then
  . .venv/bin/activate
elif [[ -f /opt/.venv/bin/activate ]]; then
  . /opt/.venv/bin/activate
fi
__set_starship_python_venv_parent
if whence -p starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
if [[ "$(uname -o)" == *"Darwin"* ]]; then
  cd $HOME/engine-room/
fi
