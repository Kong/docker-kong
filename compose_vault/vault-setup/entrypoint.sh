#!/usr/bin/env bash
set -Eeo pipefail

( curl -s -o /dev/null -w ''%{http_code}'' http://vault:8200/ui/ | grep -q 200 ) || exit 1

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

test -f /keys/keys.txt || vault operator init > /keys/keys.txt

vault operator unseal $(grep 'Key 1:' /keys/keys.txt | awk '{print $NF}')
vault operator unseal $(grep 'Key 2:' /keys/keys.txt | awk '{print $NF}')
vault operator unseal $(grep 'Key 3:' /keys/keys.txt | awk '{print $NF}')

test -f /keys/keys.txt && vault login $(grep 'Initial Root Token:' /keys/keys.txt | awk '{print substr($NF, 1, length($NF))}')

if [[ ! -f /consul/db_policy/data ]]
then
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
        revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;" \
        default_ttl="1m" \
        max_ttl="2h"
    
    vault policy write db_creds /tmp/db_creds.tpl
    touch /consul/db_policy/data
    vault token create -policy="db_creds" | grep "token " | awk '{print $2}' >> /consul/db_policy/data
fi

while vault status | grep Sealed | grep -q false; do :; done

exit 1
