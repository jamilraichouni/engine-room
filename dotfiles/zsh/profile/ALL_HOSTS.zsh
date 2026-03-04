if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi
. $DOT/zsh/zsh.zsh

# rust, cargo
[ -f $HOME/.cargo/env ] && source $HOME/.cargo/env

# fzf
source <(fzf --zsh)

# p10k
_p10k_ipt="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
if [[ -r "$_p10k_ipt" ]]; then
  source "$_p10k_ipt"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# to enable work with SOPS
gpg-agent --homedir $HOME/.gnupg --daemon 2> /dev/null
