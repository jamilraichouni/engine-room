unalias -a

# core:
alias :q='exit'
alias :qa='exit'
alias venv-deactivate='source ~/engine-room/dotfiles/zsh/bin/deactivate-venv.zsh'
if [[ "$(uname -o)" == *"Darwin"* ]]; then
  alias ls='ls --color';
else
  alias ls='ls --color --time-style=+"%Y-%m-%d|%H:%M:%S"';
fi
alias l='ls -lh'   # h makes sizes human-readable
alias ll='ls -lha' # a shows dot files
alias src='. ~/.zshrc'
alias watch='watch --color'

# functions:
alias pathprepend='/bin/zsh ~/engine-room/dotfiles/zsh/bin/pathprepend.zsh'
alias ssh='/bin/zsh ~/engine-room/dotfiles/zsh/bin/ssh.zsh'

# dirs:
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias 3rd='cd ~/dev/3rdparty'
alias ardks='cd ~/dev/dbgitlab/ar-dks'
alias bind='cd /mnt/bind'
alias c2p='cd ~/dev/dbgitlab/capella2polarion'
alias ca='cd ~/dev/github/capella-addons'
alias ccm='cd ~/dev/github/capella-collab-manager'
alias cdi='cd ~/dev/github/capella-dockerimages'
alias ck='cd ~/.config/kitty'
alias cn='cd ~/.config/nvim'
alias cra='cd ~/dev/github/capella-rest-api'
alias d='cd ~/dev'
alias dbgl='cd ~/dev/dbgitlab'
alias dot='cd ~/engine-room/dotfiles'
alias er='cd ~/engine-room'
alias gh='cd ~/dev/github'
alias gl='cd ~/dev/gitlab'
alias loc='cd ~/dev/local'
alias mbse='cd ~/dev/github/capellambse'
alias mdd='cd ~/dev/dbgitlab/mddocgen'
alias me='cd ~/dev/github/capella-model-explorer'
alias ra='cd ~/dev/github/capella-addons/rest-api'
alias tmp='cd /tmp'
alias ws='cd /opt/bind/workspaces'
alias x='cd /opt/bind/x'

# edit specific files
alias Ali='$EDITOR $DOT/zsh/aliases.zsh'
alias Doc='$EDITOR $DOT/JARDOC.md'
alias Ewt='$EDITOR ~/dev/github/working-times/data/working_times.csv'
alias Init='$EDITOR ~/.config/nvim/init.lua'
alias Lsp='$EDITOR ~/.config/nvim/lua/plugins/lsp.lua'
alias Plug='$EDITOR ~/.config/nvim/lua/plugins'
alias Zsh='$EDITOR -c"tcd $DOT/zsh" $DOT/zsh'

# tools:
alias c='capella'
alias cov='coverage run; coverage report'
alias cs='capella-studio'
alias ff='(firefox &> /dev/null & disown &> /dev/null)'
alias fonts='kitty +list-fonts'
alias grep='grep --color'
alias icat='kitty +kitten icat --align left --background=white'
alias prettifyhtml='prettier --parser html --tab-width 4 --print-width 79 --single-attribute-per-line'
alias prettifyjinja='prettier --parser jinja-template --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-jinja-template/lib/index.js"'
alias prettifyall='prettier --parser jinja-template --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs" --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-jinja-template/lib/index.js"'
alias prettifytailwind='prettier --parser html --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs"'
alias pygrep='grep --include="*.py"'
alias rpdb='nc localhost 4444'
alias termcolors='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'
alias tree='tree -C'
alias vi='$EDITOR'
alias vib="vi -c'setlocal filetype=aichat' -c'startinsert'"
alias vid='$EDITOR -c"TabooRename dev" -c"bel new +terminal" -c"wincmd k" -c"tabe +G" -c"TabooRename Git" -c"1tabn"'
alias vig='$EDITOR -c"G"'
alias vil='$EDITOR -c"Gclog"'
alias vio='$EDITOR -c"Oil"'
alias vis='([[ -f Session.vim ]] && $EDITOR -S) || $EDITOR'
alias vit='$EDITOR -c"term" -c"startinsert"'
alias wt='update_working_times'
alias xmlgrep='grep --include="*.xml"'

# git:
alias add='git add'
alias branch='git branch'
alias checkout='git checkout'
alias commit='git commit'
alias fetch='git fetch'
alias gitdiff='git difftool --no-symlinks'
alias gitdiffdir='git difftool --no-symlinks --dir-diff'
alias gitreset='git checkout -- .; git reset --hard HEAD; git clean -d --force'
alias gudbgl='git config user.name "Jamil RAICHOUNI"; git config user.email jamil.raichouni@deutschebahn.com'
alias gugh='git config user.name "Jamil RAICHOUNI"; git config user.email jamilraichouni@users.noreply.github.com'
alias gugl='git config user.name "Jamil RAICHOUNI"; git config user.email 3147782-jamilraichouni@users.noreply.gitlab.com'
alias merge='git merge'
alias pull='git pull'
alias push='git push'
alias st='git status'
alias stash='git stash'
alias switch='git switch'
alias up='git add .; git commit -m "WIP"; git push'

# misc:
alias nvimversions='dnf list --showduplicates neovim'
alias source-file='source_file'
