#!/usr/bin/env sh

sed -i 's/ENCRYPT_KEY/'`consul keygen`'/g' /tmp/*.json
cp /tmp/*.json /consul/
chown -R consul:consul /consul/*
