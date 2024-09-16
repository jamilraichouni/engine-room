[[ -f $DOT/zsh/oh-my-zsh.zsh ]] && . $DOT/zsh/oh-my-zsh.zsh
[[ -f $DOT/zsh/p10k.zsh ]] && . $DOT/zsh/p10k.zsh

# aliases MUST be sourced after oh-my-zsh !!!
unalias -a && [[ -f $DOT/zsh/aliases.zsh ]] && . $DOT/zsh/aliases.zsh

# fzf
source <(fzf --zsh)

