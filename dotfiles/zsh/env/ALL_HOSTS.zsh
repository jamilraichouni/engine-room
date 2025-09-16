[[ -f $HOME/.cargo/env ]] && . "$HOME/.cargo/env"
[[ -f $HOME/.engine_room_env ]] && . "$HOME/.engine_room_env"
export ANTHROPIC_API_KEY=$(cat $HOME/engine-room/secrets/anthropic_api_key.token)
export BAT_CONFIG_PATH=$HOME/engine-room/dotfiles/bat/config/bat.conf
export BAT_THEME="JAR"
export CLAUDE_CONFIG_DIR=$HOME/engine-room/dotfiles/claude
export DISPLAY="host.docker.internal:0.0"
export DOT=$HOME/engine-room/dotfiles
export EDITOR=nvim
export ENV GPG_TTY=$TTY  # see: https://unix.stackexchange.com/a/608921
export ER=$HOME/engine-room
export FZF_CTRL_T_OPTS='--color="fg+:#ffffff,fg:#608b4e,hl:#ff0000,hl+:#ff0000" --history-size=10000 --preview="bat --style=changes,header,numbers --color=always {}"'
export FZF_DEFAULT_OPTS='--color="fg+:#ffffff,fg:#608b4e,hl:#ff0000,hl+:#ff0000" --history-size=10000'
export GITLAB_PAT=$([[ -e /run/secrets/GITLAB_PAT ]] && cat /run/secrets/GITLAB_PAT)
[[ -d /mnt/volume ]] && export HISTFILE=/mnt/volume/zsh_history || export HISTFILE=$HOME/.zsh_history
export JAVA_HOME=/usr/lib/jvm/jdk
export JQ_COLORS="1;36:0;39:0;39:0;39:0;32:1;39:1;39"
export KEEPASS_DB_PASSWORD=$([[ -e /run/secrets/KEEPASS_DB_PASSWORD ]] && cat /run/secrets/KEEPASS_DB_PASSWORD)
export KUBECONFIG=$HOME/dev/dbgitlab/gitops/access/ardks-iat-nzfcw.kubeconfig
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en:C
export MANPAGER="nvim +Man! "
export NVM_DIR="$HOME/.nvm"
export NVM_BIN="$(realpath $NVM_DIR/versions/node/v*/bin)"
export OPENAI_API_KEY=$([[ -e /run/secrets/OPENAI_API_KEY ]] && cat /run/secrets/OPENAI_API_KEY)
export SHELL=/bin/zsh
if [[ "$HOST" == "engine-room-"* ]]; then
  export SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
fi
if [[ "$(uname -o)" != *"Darwin"* ]]; then
  export TERM=xterm-kitty
  export TERMINFO=/usr/share/terminfo
  sudo chmod 666 /run/secrets/GITLAB_PAT
  sudo chmod 666 /run/secrets/KEEPASS_DB_PASSWORD
  sudo chmod 666 /run/secrets/OPENAI_API_KEY
fi
export TZ=":/usr/share/zoneinfo/Europe/Berlin"
export VISUAL=nvim
export VOL=/mnt/volume

export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.krew/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/engine-room/dotfiles/zsh/bin:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$(realpath $HOME/.nvm/versions/node/v*/bin):$PATH
if [[ -d $(realpath $HOME/.local/share/uv/python/cpython-*-linux-aarch64-gnu/bin) ]]; then
  export PATH=$(realpath $HOME/.local/share/uv/python/cpython-*-linux-aarch64-gnu/bin):$PATH
fi
export REQUESTS_CA_BUNDLE=$HOME/engine-room/secrets/ssl_certificates.pem
export SSL_CERT_FILE=$REQUESTS_CA_BUNDLE
export UV_NO_SYNC=1

[[ -f /etc/zshenv.secrets ]] && . /etc/zshenv.secrets
