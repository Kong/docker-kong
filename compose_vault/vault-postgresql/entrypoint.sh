#!/usr/bin/env bash
set -Eeo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env POSTGRES_PASSWORD

export VAULT_ADDR=http://vault:8200

vault operator init > keys.txt
vault operator unseal $(grep 'Key 1:' keys.txt | awk '{print $NF}')
vault operator unseal $(grep 'Key 2:' keys.txt | awk '{print $NF}')
vault operator unseal $(grep 'Key 3:' keys.txt | awk '{print $NF}')
vault login $(grep 'Initial Root Token:' keys.txt | awk '{print substr($NF, 1, length($NF))}')

vault secrets enable database

vault write database/config/$POSTGRES_DB \
    plugin_name=postgresql-database-plugin \
    allowed_roles="vaultrole" \
    connection_url="postgres://{{username}}:{{password}}@postgres:5432/$POSTGRES_DB?sslmode=disable" \
    username="$POSTGRES_USER" \
    password="$POSTGRES_PASSWORD"

vault write database/roles/vaultrole \
    db_name=$POSTGRES_DB \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

vault policy write db_creds /tmp/db_creds.tpl

vault token create -policy="db_creds" | grep token | head -1 | awk '{print $2}' >> /consul/db_policy/data

