#!/bin/bash

mkdir -p dtool_lookup_server
mkdir -p token_generator_ldap

openssl genrsa -out dtool_lookup_server/jwt_key 2048
openssl rsa -in dtool_lookup_server/jwt_key -pubout -outform PEM -out dtool_lookup_server/jwt_key.pub

cp dtool_lookup_server/jwt_key token_generator_ldap/jwt_key
cp dtool_lookup_server/jwt_key.pub token_generator_ldap/jwt_key.pub
