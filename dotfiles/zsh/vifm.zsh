#!/usr/bin/env zsh

if [ -d $DOT/vifm-config ]; then
    [[ -L $HOME/.config/vifm ]] || (rm -rf $HOME/.config/vifm && ln -s $DOT/vifm-config $HOME/.config/vifm)
fi