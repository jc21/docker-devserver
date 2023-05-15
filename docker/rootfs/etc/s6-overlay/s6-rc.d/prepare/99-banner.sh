#!/command/with-contenv bash
# shellcheck shell=bash

set -e
set +x

. /etc/os-release

echo "
-------------------------------------
    ____  _______    __
   / __ \/ ____/ |  / /
  / / / / __/  | | / /
 / /_/ / /___  | |/ /
/_____/_____/  |___/
-------------------------------------
User:      $DEVUSER PUID:$PUID ID:$(id -u "$DEVUSER") GROUP:$(id -g "$DEVUSER")
Group:     $DEVGROUP PGID:$PGID ID:$(get_group_id "$DEVGROUP")
OpenResty: ${OPENRESTY_VERSION:-unknown}
Debian:    ${VERSION_ID:-unknown}
Kernel:    $(uname -r)
-------------------------------------
"
