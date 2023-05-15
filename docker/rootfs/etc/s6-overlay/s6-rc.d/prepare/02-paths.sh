#!/command/with-contenv bash
# shellcheck shell=bash

set -e

log_info 'Checking paths ...'

# Create required folders
mkdir -p \
	/run/nginx \
	/tmp/nginx/body \
	/var/log/nginx \
	/var/lib/nginx/cache/public \
	/var/lib/nginx/cache/private \
	/var/cache/nginx/proxy_temp

touch /var/log/nginx/error.log || true
chmod 777 /var/log/nginx/error.log || true
chmod -R 777 /var/cache/nginx || true
