[[ -f $DOT/zsh/oh-my-zsh.zsh ]] && . $DOT/zsh/oh-my-zsh.zsh
[[ -f $DOT/zsh/p10k.zsh ]] && . $DOT/zsh/p10k.zsh

# aliases MUST be sourced after oh-my-zsh !!!
unalias -a && [[ -f $DOT/zsh/aliases.zsh ]] && . $DOT/zsh/aliases.zsh

# fzf
source <(fzf --zsh)

# venv handling with `cd` command
function __python_venv_on_cd() {
  setopt local_options err_return

  if (($+VIRTUAL_ENV)) && [[ $PWD != ${VIRTUAL_ENV%/*}/* ]]; then
    deactivate > /dev/null 2>&1 || unset VIRTUAL_ENV
  fi

  if ! (($+VIRTUAL_ENV)) && [[ -f .venv/bin/activate ]]; then
      . .venv/bin/activate
  fi
}

chpwd_functions+=(__python_venv_on_cd)

# when a terminal starts (especially in nvim), activate venv if .venv exists
[[ -f .venv/bin/activate ]] && . .venv/bin/activate
