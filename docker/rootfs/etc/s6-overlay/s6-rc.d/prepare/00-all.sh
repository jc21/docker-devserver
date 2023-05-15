#!/command/with-contenv bash
# shellcheck shell=bash

set -e

. /bin/common.sh

if [ "$(id -u)" != "0" ]; then
	log_fatal "This docker container must be run as root, do not specify a user.\nYou can specify PUID and PGID env vars to run processes as that user and group after initialization."
fi

if [ "$(is_true "$DEBUG")" = '1' ]; then
	set -x
fi

. /etc/s6-overlay/s6-rc.d/prepare/01-usergroup.sh
. /etc/s6-overlay/s6-rc.d/prepare/02-paths.sh
. /etc/s6-overlay/s6-rc.d/prepare/03-ownership.sh
. /etc/s6-overlay/s6-rc.d/prepare/99-banner.sh
