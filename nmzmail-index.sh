#!/bin/bash
# nmzmail-index.sh - Angel Olivera <redondos@aolivera.com.ar>

# Tweak MAX_MAIL_DIRS at nmzmail compile time. (default=32)
# EXCEPTIONS is in bash glob syntax, see bash(1) for "Pathname Expansion"

BASE=~/.maildir
EXCEPTIONS="Spam Search sys*"

shopt -s dotglob extglob
EXCEPTIONS=${EXCEPTIONS// /|}

for mailbox in $BASE/!(+([^.])|.+($EXCEPTIONS)); do
	ARGS[i++]="$mailbox"
done 

# Uncomment to include the inbox
# ARGS[i++]="$BASE/cur" && ARGS[i++]="$BASE/new"

nmzmail -i "${ARGS[@]}"
