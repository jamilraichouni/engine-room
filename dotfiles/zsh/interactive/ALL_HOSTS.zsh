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
    printf >&2 '\x1b[1m*** Leaving project venv at %q\n' $VIRTUAL_ENV
    deactivate || unset VIRTUAL_ENV
  fi

  if ! (($+VIRTUAL_ENV)) && [[ -f .venv/bin/activate ]]; then
    if [[ -d .jj ]]; then
      local trustfile=.jj/repo/trusted_venv
    elif [[ -d .git ]]; then
      local trustfile=.git/info/trusted_venv
    else
      local trustfile=~/.config/zsh/trusted_venvs/${PWD//\//%}
    fi

    if [[ -e $trustfile ]]; then
      . .venv/bin/activate
      printf >&2 '\x1b[1m*** Entered project venv at %q\n' $VIRTUAL_ENV
    else
      printf >&2 '\x1b[1m\x1b[31m*** ERROR:\x1b[m\x1b[1m project venv is not trusted, not activating\x1b[m\n'
      printf >&2 'To mark this venv as trusted, run:\n'
      printf >&2 '\n'
      printf >&2 '  touch %q\n' "$trustfile"
    fi
  fi
}

chpwd_functions+=(__python_venv_on_cd)

# when a terminal starts (especially in nvim), activate venv if .venv exists
[[ -f .venv/bin/activate ]] && . .venv/bin/activate
