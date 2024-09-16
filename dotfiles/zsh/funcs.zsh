#!/usr/bin/env zsh
bak() {
    # Check if the argument is provided
    if [ -z "$1" ]; then
        echo "Usage: bak <file_or_folder_path>"
        return 1
    fi

    # Convert the provided path to an absolute path
    local input_path="$1"
    local abs_path=$(realpath "$input_path")

    # Check if the path exists
    if [ ! -e "$abs_path" ]; then
        echo "Error: The path '$abs_path' does not exist."
        return 1
    fi

    # Create the backup path
    local backup_path="${abs_path}.bak"

    # Copy the file or folder to the backup path
    if [ -d "$abs_path" ]; then
        cp -r "$abs_path" "$backup_path"
    else
        cp "$abs_path" "$backup_path"
    fi

    echo "Backup created at '$backup_path'"
}

cd_func() {
    local x2 the_new_dir adir index
    local -i cnt

    if [[ $1 == "--" ]]; then
        dirs -v
        return 0
    fi
    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME

    if [[ ${the_new_dir:0:1} == '-' ]]; then
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi
    #
    # '~' has to be substituted by ${HOME}
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

    # Now change to the new dir and add to the top of the stack
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)
    # Trim down everything beyond 11th entry
    popd -n +11 2> /dev/null 1> /dev/null
    # Remove any other occurence of this dir, skipping the top of the stack
    for ((cnt = 1; cnt <= 10; cnt++)); do
        x2=$(dirs +${cnt} 2> /dev/null)
        [[ $? -ne 0 ]] && return 0
        [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
        if [[ "${x2}" == "${the_new_dir}" ]]; then
            popd -n +$cnt 2> /dev/null 1> /dev/null
            cnt=cnt-1
        fi
    done
    return 0
}
alias cd=cd_func

cleanpy_func() {
    find $PWD -depth -type d -name '__pycache__' -exec rm -Rf {} \;
    find $PWD -depth -type f -name '*.pyc' -exec rm -f {} \;
}
h2() {
    echo "$1;" | java -cp ./h2/bin/h2-1.3.169.jar org.h2.tools.Shell -user wsa -url jdbc:h2:tcp://172.17.0.3:5234/automated-train
}

json() {
  curl $@ -s | bat -l JSON --paging=auto
}

source_file() {
    file="${1:-.env}"
    if [ -f "$file" ]; then
        set -a
        source "$file"
        set +a
    else
        echo "$file file not found"
    fi
}

pathprepend() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:${PATH:+"$PATH"}"
    fi
}

urlencode() {
    if [ -n "$1" ]; then
        python -c "from urllib.parse import quote; print(quote('$1'))"
    fi
}

venv() {
    # `pynvim` is needed by Python plugins (e. g. https://github.com/madox2/vim-ai)

    # git+https://github.com/bretello/pdbpp.git@fix-on-3.11 \

    [[ -f .python-version ]] && rm .python-version
    VERSION=${1:-3.12.6}
    VENV_NAME=$(basename $(pwd))
    echo "pyenv virtualenv $VERSION $VENV_NAME"
    pyenv virtualenv $VERSION $VENV_NAME
    echo $VENV_NAME > .python-version
    python -m pip install --upgrade pip
    pip install -r $DOT/requirements.txt
    # python -m pip install --force-reinstall $HOME/dev/3rdparty/mypy_mypyc-wheels/wheelhouse/mypy-0.991-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl;
    echo "/home/nörd/engine-room/dotfiles/" > $(realpath $HOME/.pyenv/versions/$VENV_NAME/lib/python*)/site-packages/extendpath.pth
    echo "import logger" > $(realpath $HOME/.pyenv/versions/$VENV_NAME/lib/python*)/site-packages/logger.pth
}

update_working_times() {
    CWD=$(pwd)
    cd ~/dev/github/working-times
    python -m working_times
    cd $CWD
}
