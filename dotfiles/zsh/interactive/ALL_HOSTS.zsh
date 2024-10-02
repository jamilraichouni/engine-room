. $DOT/zsh/oh-my-zsh.zsh
. $DOT/zsh/p10k.zsh

# aliases MUST be sourced after oh-my-zsh !!!
unalias -a && . $DOT/zsh/aliases.zsh

# fzf
source <(fzf --zsh)

