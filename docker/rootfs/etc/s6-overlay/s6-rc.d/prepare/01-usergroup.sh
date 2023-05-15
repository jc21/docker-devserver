#!/command/with-contenv bash
# shellcheck shell=bash

set -e

log_info "Configuring $DEVUSER user ..."

if id -u "$DEVUSER" 2>/dev/null; then
	# user already exists
	usermod -u "$PUID" "$DEVUSER"
else
	# Add user
	useradd -o -u "$PUID" -U -d "$DEVHOME" -s /bin/false "$DEVUSER"
fi

log_info "Configuring $DEVGROUP group ..."
if [ "$(get_group_id "$DEVGROUP")" = '' ]; then
	# Add group. This will not set the id properly if it's already taken
	groupadd -f -g "$PGID" "$DEVGROUP"
else
	groupmod -o -g "$PGID" "$DEVGROUP"
fi

# Set the group ID and check it
groupmod -o -g "$PGID" "$DEVGROUP"
if [ "$(get_group_id "$DEVGROUP")" != "$PGID" ]; then
	echo "ERROR: Unable to set group id properly"
	exit 1
fi

# Set the group against the user and check it
usermod -G "$PGID" "$DEVGROUP"
if [ "$(id -g "$DEVUSER")" != "$PGID" ] ; then
	echo "ERROR: Unable to set group against the user properly"
	exit 1
fi

# Home for user
mkdir -p "$DEVHOME"
chown -R "$PUID:$PGID" "$DEVHOME"
