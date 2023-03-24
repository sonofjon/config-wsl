#!/bin/bash
#
# Usage:
#
#  backup.sh [ -v ] [ -n ]
#
# Symlink in bin directory
#
#   ln -s ~/dotfiles/config-wsl/backup.sh ~/bin/backup.sh
#
# and add to user crontab, e.g.
#
#   1 5 * * * ~/bin/backup.sh
#
# or symlink in anacron directory, e.g.
#
#   ln -s ~/dotfiles/config-wsl/backup.sh /etc/cron.hourly/backup
#

WINUSER=$(powershell.exe '$env:UserName' | tr -d '\r')
SOURCE=$HOME/
DEST=/mnt/c/Users/"$WINUSER"/Backup/wsl/
EXCLUDE_FILE=$HOME/dotfiles/config-wsl/exclude.rsync
LOG_FILE=$HOME/backup.log

rsync -a --delete $@ --exclude-from=$EXCLUDE_FILE "$SOURCE" "$DEST" --log-file="$LOG_FILE"
