[[ -f $HOME/.cargo/env ]] && . "$HOME/.cargo/env"
[[ -f $HOME/.engine_room_env ]] && . "$HOME/.engine_room_env"
export DOT=$HOME/engine-room/dotfiles
export EDITOR=nvim
export ENV GPG_TTY=$TTY  # see: https://unix.stackexchange.com/a/608921
export ER=$HOME/engine-room
export FZF_CTRL_T_OPTS='--color="fg+:#ffffff,fg:#608b4e,hl:#ff0000,hl+:#ff0000" --history-size=10000 --preview="bat --style=changes,header,numbers --color=always {}"'
export FZF_DEFAULT_OPTS='--color="fg+:#ffffff,fg:#608b4e,hl:#ff0000,hl+:#ff0000" --history-size=10000'
[[ -d /mnt/volume ]] && export HISTFILE=/mnt/volume/zsh_history || export HISTFILE=$HOME/.zsh_history
export JAVA_HOME=/usr/lib/jvm/jdk
export JQ_COLORS="1;36:0;39:0;39:0;39:0;32:1;39:1;39"
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en:C
export MANPAGER="nvim +Man! "
export NVIM_DOCS="/opt/nvim/share/nvim/runtime/doc"
export NVM_BIN="$(realpath $NVM_DIR/versions/node/v*/bin)"
export NVM_DIR="$HOME/.nvm"
export PYTHON_COLORS=1
export SHELL=/bin/zsh
if [[ "$HOST" == "engine-room-"* ]]; then
  export SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
fi
if [[ "$(uname -o)" != *"Darwin"* ]]; then
  export DISPLAY="host.docker.internal:0.0"
  export KUBECONFIG=$HOME/dev/dbgitlab/gitops/access/ardks-iat-nzfcw.kubeconfig
  export PATH=/opt/.venv/bin:$PATH
  export TERM=xterm-kitty
  export TERMINFO=/usr/share/terminfo
  export _OLD_VIRTUAL_PATH="$PATH"
  export VIRTUAL_ENV=/opt/.venv
  export VOL=/mnt/volume
  sudo chmod 666 /run/secrets/GITLAB_PAT
fi
export TZ=":/usr/share/zoneinfo/Europe/Berlin"
export VISUAL=nvim
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.krew/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/engine-room/dotfiles/zsh/bin:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$(realpath $HOME/.nvm/versions/node/v*/bin):$PATH
export REQUESTS_CA_BUNDLE=$HOME/engine-room/secrets/ssl_certificates.pem
export SSL_CERT_FILE=$REQUESTS_CA_BUNDLE
export UV_CACHE_DIR=/mnt/volume/cache/uv
export UV_CONFIG_FILE=$HOME/engine-room/dotfiles/uv.toml
export UV_DEFAULT_INDEX=https://bahnhub.tech.rz.db.de/artifactory/api/pypi/pypi-remote/simple
export UV_INDEX=https://bahnhub.tech.rz.db.de/artifactory/api/pypi/pypi-remote/pypi
export UV_PYTHON_DOWNLOADS=auto
export UV_PYTHON_INSTALL_DIR=/opt/python
export UV_UNMANAGED_INSTALL=/usr/bin/

[[ -f /etc/zshenv.secrets ]] && . /etc/zshenv.secrets
