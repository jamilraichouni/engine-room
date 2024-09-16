FROM fedora:40
LABEL maintainer="Jamil André RAICHOUNI <raichouni@gmail.com>"

ENV TERM=xterm-kitty
ENV TERMINFO=/usr/share/terminfo

# system pkg manager installs {{{
RUN dnf --color yes --refresh -y install \
  cargo \
  ctags \
  gcc \
  gcc-c++ \
  git \
  golang \
  # e. g. to be able to ping hosts
  iputils \
  java-17-openjdk-devel \
  kitty \
  kitty-terminfo \
  # kitty \
  lsof \
  luarocks \
  make \
  neovim \
  # e. g. `netstat`
  net-tools \
  # To remote debug using the Python package `rpdb`
  # see https://github.com/tamentis/rpdb
  nmap-ncat \
  passwd \
  pip \
  openssl \
  pkg-config \
  sudo \
  tree \
  unrar \
  unzip \
  vim \
  wget \
  which \
  zip \
  zsh
# RUN ln -sf /usr/bin/batcat /usr/local/bin/bat
# }}}

# use zsh for RUN commands {{{
SHELL ["/bin/zsh", "-c"]
ENV SHELL=/bin/zsh
RUN usermod --shell /bin/zsh root
# }}}

# locale and time zone  {{{
RUN dnf install --color yes -y \
  glibc-locale-source \
  glibc-langpack-en && \
  localedef --force -i en_US -f UTF-8 en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en:C
ENV TZ=":/usr/share/zoneinfo/Europe/Berlin"
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "LANGUAGE=en_US:en:C" >> /etc/locale.conf
# }}}

# Install nerd font {{{
ARG FONT_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/SourceCodePro.tar.xz
RUN FONT_FILE=$(basename ${FONT_URL} | rev | cut -d/ -f1 | rev) && \
  mkdir -p /usr/local/share/fonts && \
  curl -Lo /usr/local/share/fonts/${FONT_FILE} ${FONT_URL} && \
  tar -C /usr/local/share/fonts -xvf /usr/local/share/fonts/${FONT_FILE} && \
  rm /usr/local/share/fonts/${FONT_FILE} && \
  fc-cache -f -v
# }}}

# set root passwd and get root via `su - root` {{{
RUN echo "root:" | chpasswd && \
  echo -e "alias :q='exit'\nalias :qa='exit'\nalias ls='ls --color'\nalias l='ls -lh'\nalias ll='ls -lha'" >> /root/.zshrc
# }}}

# Add user 'nerd' {{{
RUN useradd --badname -l -m -s /bin/zsh --home-dir=/Users/jamilraichouni nerd && \
  # set password to "nerd"
  echo "nerd:nerd" | chpasswd && \
  echo -e "alias :q='exit'\nalias :qa='exit'\nalias ls='ls --color'\nalias l='ls -lh'\nalias ll='ls -lha'\nalias vi='nvim'" >> /Users/jamilraichouni/.zshrc

# disable hint that sudo is dangerous and allow sudo w/o passwd
RUN echo "Defaults lecture = never" >> /etc/sudoers.d/privacy && \
  echo "nerd ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# }}}

USER nerd

# setup for user nerd {{{
RUN mkdir -p $HOME/.config && \
  echo "LANG=en_US.UTF-8" > ~/.config/locale.conf && \
  echo "LANGUAGE=en_US:en:C" >> $HOME/.config/locale.conf

# vim
ENV EDITOR=vim
ENV VISUAL=vim

# nvm and node
ENV NVM_DIR=/Users/jamilraichouni/.nvm
# https://github.com/nvm-sh/nvm/releases
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN zsh -c "source ${NVM_DIR}/nvm.sh && nvm install --lts"

# npm
ENV NPM_DIR=/Users/jamilraichouni/.local/share/npm
RUN [[ -d ${NPM_DIR} ]] || mkdir -p ${NPM_DIR}

# yarn
RUN zsh -c "source ${NVM_DIR}/nvm.sh && nvm use default && \
  npm install -g --prefix ${NPM_DIR} yarn"
RUN echo -e "export PATH=/Users/jamilraichouni/.local/share/npm/bin:$PATH" >> /Users/jamilraichouni/.zshrc
# }}}

# setup nvim {{{
RUN mkdir -p /Users/jamilraichouni/.config/nvim/lua/init && \
  mkdir -p /Users/jamilraichouni/.config/nvim/lua/plugins

COPY lazy-lock.json /Users/jamilraichouni/.config/nvim
COPY init.lua /Users/jamilraichouni/.config/nvim/
COPY lua/init/* /Users/jamilraichouni/.config/nvim/lua/init
COPY lua/plugins/* /Users/jamilraichouni/.config/nvim/lua/plugins
RUN nvim --headless -c'source ~/.config/nvim/init.lua' -c'Lazy! install' -c'qa' && \
  nvim --headless -c'TSInstallSync java' -c'q'
USER root
RUN chown -R nerd:nerd /Users/jamilraichouni/.config
USER nerd
# }}}

WORKDIR /Users/jamilraichouni/.config/nvim
CMD ["/bin/zsh"]
