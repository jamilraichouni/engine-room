if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi
. $DOT/zsh/funcs.zsh
. $DOT/zsh/zsh.zsh

# rust, cargo
[ -f $HOME/.cargo/env ] && source $HOME/.cargo/env

# fzf
source <(fzf --zsh)

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# # docker
# [[ -e /var/run/docker.sock ]] && sudo chmod 777 /var/run/docker.sock

# to enable work with SOPS
gpg-agent --homedir $HOME/.gnupg --daemon 2> /dev/null
