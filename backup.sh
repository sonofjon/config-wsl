#!/bin/bash
#
# Usage:
#
#  backup.sh [ -v ] [ -n ]
#
# Add to user crontab, e.g.
#
#   1 5 * * * ~/bin/backup.sh
#

WINUSER=$(powershell.exe '$env:UserName' | tr -d '\r')
SOURCE=$HOME/
DEST=/mnt/c/Users/$WINUSER/Backup/wsl/
EXCLUDE_FILE=$HOME/dotfiles/config-wsl/exclude.rsync

rsync -a --delete $@ --exclude-from=$EXCLUDE_FILE "$SOURCE" "$DEST"
