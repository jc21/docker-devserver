#!/bin/bash

set -e

CYAN='\E[1;36m'
BLUE='\E[1;34m'
YELLOW='\E[1;33m'
RED='\E[1;31m'
RESET='\E[0m'
export CYAN BLUE YELLOW RED RESET

PUID=${PUID:-0}
PGID=${PGID:-0}

DEVUSER=dev
DEVGROUP=dev
DEVHOME=/tmp/devuserhome
export DEVUSER DEVGROUP DEVHOME

if [[ "$PUID" -ne '0' ]] && [ "$PGID" = '0' ]; then
	# set group id to same as user id,
	# the user probably forgot to specify the group id and
	# it would be rediculous to intentionally use the root group
	# for a non-root user
	PGID=$PUID
fi

export PUID PGID

log_info () {
	echo -e "${BLUE}❯ ${CYAN}$1${RESET}"
}

log_warn () {
	echo -e "${BLUE}❯ ${YELLOW}WARNING: $1${RESET}"
}

log_error () {
	echo -e "${RED}❯ $1${RESET}"
}

log_fatal () {
	echo -e "${RED}--------------------------------------${RESET}"
	echo -e "${RED}ERROR: $1${RESET}"
	echo -e "${RED}--------------------------------------${RESET}"
	/run/s6/basedir/bin/halt
	exit 1
}

# param $1: group_name
get_group_id () {
	if [ "${1:-}" != '' ]; then
		getent group "$1" | cut -d: -f3
	fi
}

# param $1: value
is_true () {
	VAL=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
	if [ "$VAL" == 'true' ] || [ "$VAL" == 'on' ] || [ "$VAL" == '1' ] || [ "$VAL" == 'yes' ]; then
		echo '1'
	else
		echo '0'
	fi
}
