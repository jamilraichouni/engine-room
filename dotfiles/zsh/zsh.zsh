#!/usr/bin/env zsh

setopt dotglob  # copy/ move .dot files/ dirs

setopt autopushd    # cd automatically pushes old dir onto dir stack
setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

setopt CDABLE_VARS  # expand the expression (allows 'cd -2/tmp')

# shell history:
export SAVEHIST=1000000  # No of cmds stored in hist file
export HISTSIZE=1000000  # No of cmds loaded into RAM from hist file
setopt INC_APPEND_HISTORY       # cmds are added to the history immediately

# home/ end keys:
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "\e[3~" delete-char

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{9}%b%f'

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
NEWLINE=$'\n'
autoload -Uz compinit && compinit

if [[ -n $TERM ]] && [[ $TERM == "xterm-kitty" ]]; then
    alias ssh='kitty +kitten ssh'
fi
