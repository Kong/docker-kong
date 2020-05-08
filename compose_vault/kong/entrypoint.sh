#!/usr/bin/env bash
set -Eeo pipefail

test -f /consul/db_policy/data || exit 1

export CONSUL_ADDR="http://consul-bootstrap:8500" && \
export VAULT_ADDR="http://vault:8200" && \
export VAULT_TOKEN="$(cat /consul/db_policy/data)"

consul-template -template="/etc/kong/kong.conf.template:/etc/kong/kong.conf" -once

kong migrations bootstrap && \
kong start

consul-template -template="/etc/kong/kong.conf.template:/etc/kong/kong.conf:kong restart"
