unalias -a

alias :q='exit'
alias :qa='exit'
alias ls='ls --color --time-style=+"%Y-%m-%d|%H:%M:%S"'
alias l='ls -lh'   # h makes sizes human-readable
alias ll='ls -lha' # a shows dot files
alias src='. ~/.zshrc'
alias watch='watch --color'

# dirs:
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd='cd_func'

alias 3rd='cd ~/dev/3rdparty'
alias ardks='cd ~/dev/dbgitlab/ar-dks'
alias bind='cd /mnt/bind'
alias cdenv='cd ~/dev/github/env'
alias c2p='cd ~/dev/dbgitlab/capella2polarion'
alias ca='cd ~/dev/github/capella-addons'
alias ccm='cd ~/dev/github/capella-collab-manager'
alias cdi='cd ~/dev/github/capella-dockerimages'
alias cds='cd ~/dev/dbgitlab/capella-diagram-service'
alias ck='cd ~/.config/kitty'
alias cme='cd ~/dev/dbgitlab/capella-model-editor'
alias cn='cd ~/.config/nvim'
alias cra='cd ~/dev/github/capella-rest-api'
alias crb='cd ~/dev/github/capella-rm-bridge'
alias d='cd ~/dev'
alias di='cd ~/dev/github/devimage'
alias dbgl='cd ~/dev/dbgitlab'
alias dev='cd ~/dev'
alias dot='cd /mnt/volume/data/dotfiles'
alias ease='cd ~/dev/dbgitlab/ease-scripts'
alias gh='cd ~/dev/github'
alias gl='cd ~/dev/gitlab'
alias loc='cd ~/dev/local'
alias mbse='cd ~/dev/github/capellambse'
alias mdd='cd ~/dev/dbgitlab/mddocgen'
alias ra='cd ~/dev/github/capella-addons/rest-api'
alias rbp='cd ~/dev/dbgitlab/rm-bridge-polarion'
alias setjar='cd ~/dev/dbgitlab/setjar'
alias tmp='cd ~/tmp'
alias x='cd ~/x'

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
alias vi='nvim'
alias vib="vi -c'setlocal filetype=aichat' -c'startinsert'"
alias vid='nvim -c"TabooRename dev" -c"bel new +terminal" -c"wincmd k" -c"tabe +G" -c"TabooRename Git" -c"1tabn"'
alias vig='nvim -c"G"'
alias vil='nvim -c"Gclog"'
alias vio='nvim -c"Oil"'
alias vis='([[ -f Session.vim ]] && nvim -S) || nvim'
alias vit='nvim -c"term" -c"startinsert"'
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