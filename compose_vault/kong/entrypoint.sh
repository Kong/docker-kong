#!/usr/bin/env bash
set -Eeo pipefail

test -f /vault/db_policy/data || exit 1

export VAULT_ADDR="http://vault:8200" && \
export VAULT_TOKEN="$(cat /vault/db_policy/data)"

consul-template -template="/etc/kong/kong.conf.template:/etc/kong/kong.conf" -once

kong migrations bootstrap && \
kong start

consul-template -template="/etc/kong/kong.conf.template:/etc/kong/kong.conf:kong restart"
