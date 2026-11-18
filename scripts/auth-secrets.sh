#!/bin/sh
# Sets the auth stack's "auth" secrets on prod from the old serverconfig .env.
# usage: auth-secrets.sh <old .env> [--dry-run]
set -eu
umask 077
f=$(mktemp); trap 'rm -f "$f"' EXIT
# names stay as in the old .env; stkr lower-cases them, and a name set twice takes the last one
grep -E '^(LLDAP_(JWT_SECRET|KEY_SEED|BASE_DN|ADMIN_EMAIL|ADMIN_PASSWORD)|AUTHELIA_(SESSION_SECRET|STORAGE_ENCRYPTION_KEY|JWT_SECRET|OIDC_HMAC_SECRET)|(IMMICH|HUGINN|RUSTFS)_OIDC_CLIENT_SECRET_HASH)=.' "$1" > "$f"
n=$(cut -d= -f1 "$f" | sort -u | wc -l)
[ "$n" = 12 ] || { echo "expected 12 names in $1, found $n" >&2; exit 1; }
stkr params import "$f" --stack auth --env prod --collection auth --secret ${2:+"$2"}
