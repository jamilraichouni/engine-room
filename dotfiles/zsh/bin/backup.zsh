#!/bin/zsh

[[ -f /mnt/volume/zsh_history ]] && cp /mnt/volume/zsh_history ~/googledrive/engine-room/zsh_history
rsync -avh --delete --progress --exclude-from="$HOME/engine-room/dotfiles/backup_volume_rsync_exclude.list" ~/engine-room/secrets/ ~/googledrive/engine-room/secrets
rsync -avh --delete --progress --exclude-from="$HOME/engine-room/dotfiles/backup_volume_rsync_exclude.list" /mnt/volume/dev/ ~/googledrive/engine-room/dev
