. $DOT/zsh/funcs.zsh

. $DOT/zsh/oh-my-zsh.zsh
. $DOT/zsh/zsh.zsh
. $DOT/zsh/p10k.zsh

. $DOT/zsh/vifm.zsh

# fzf
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
# [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# pyenv
if command -v pyenv > /dev/null; then
  pathprepend $PYENV_ROOT/bin
  eval "$(pyenv init -)"
  # Load pyenv-virtualenv automatically when a .python-version file is found:
  [[ -n $PYENV_VIRTUALENV_INIT && $PYENV_VIRTUALENV_INIT == 1 ]] || eval "$(pyenv virtualenv-init -)"
fi


# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# npm
export NPM_DIR=$HOME/.local/share/npm # for nvim-lspconfig
[[ -L $NPM_DIR ]] || [[ -d $NPM_DIR ]] || mkdir -p $NPM_DIR
if [ -d /mnt/volume/data/npm ]; then
    [[ -L $NPM_DIR ]] || (rm -rf $NPM_DIR && ln -s /mnt/volume/data/npm $NPM_DIR)
fi
pathprepend $NPM_DIR/bin

# docker
sudo chmod 777 /var/run/docker.sock

unalias -a
. $DOT/zsh/aliases.zsh
