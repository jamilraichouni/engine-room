#!/usr/bin/env zsh

[[ -d $HOME/.pyenv ]] || return

NAME=pyenv
# condition to check if dir is not empty and sync if it is empty
[[ -d $VOLUME/$NAME/bin ]] \
    || (
        [[ -d $MNT_FALLBACK/$NAME ]] \
            && echo "Sync $MNT_FALLBACK/$NAME -> $VOLUME/$NAME..." \
            && rsync -az $MNT_FALLBACK/$NAME/ $VOLUME/$NAME
    )

# IPython:
[[ -L $HOME/.ipython ]] || ([[ -d $DOT/ipython ]] && ln -sf $DOT/ipython $HOME/.ipython)

[[ -L $HOME/.$NAME ]] || ([[ -d $VOLUME/$NAME ]] && rm -rf ~/.$NAME && ln -sf $VOLUME/$NAME $HOME/.$NAME)

for F in \
    pdbrc \
    pdbrc.py; do
    [[ -L $HOME/.$F ]] || ([[ -f $DOT/$F ]] && ln -fs $DOT/$F $HOME/.$F)
done

[[ -L $HOME/pygmentsstyles.py ]] || ([[ -f $DOT/pygmentsstyles.py ]] && ln -fs $DOT/pygmentsstyles.py $HOME/pygmentsstyles.py)

# pyenv:
export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

command -v pyenv > /dev/null || pathprepend $PYENV_ROOT/bin
eval "$(pyenv init -)"

# Load pyenv-virtualenv automatically when a .python-version file is found:
[[ -n $PYENV_VIRTUALENV_INIT && $PYENV_VIRTUALENV_INIT == 1 ]] || eval "$(pyenv virtualenv-init -)"

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
