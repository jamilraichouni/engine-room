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

urlencode() {
  if [ -n "$1" ]; then
    python -c "from urllib.parse import quote; print(quote('$1'))"
  fi
}

venv() {
  # `pynvim` is needed by Python plugins (e. g. https://github.com/madox2/vim-ai)

  # git+https://github.com/bretello/pdbpp.git@fix-on-3.11 \

  [[ -f .python-version ]] && rm .python-version
  VERSION=${1:-3.13.5}
  uv venv --python=$VERSION .venv
  source .venv/bin/activate
  uv pip install --upgrade pip
  uv pip install -r $DOT/requirements.txt
  uv tool install pre-commit --with pre-commit-uv --force-reinstall
  [[ -f pyproject.toml ]] && uv sync --inexact
}
