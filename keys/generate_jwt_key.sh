#!/bin/bash

mkdir -p dserver
mkdir -p token_generator_ldap

openssl genrsa -out dserver/jwt_key 2048
openssl rsa -in dserver/jwt_key -pubout -outform PEM -out dserver/jwt_key.pub

cp dserver/jwt_key token_generator_ldap/jwt_key
cp dserver/jwt_key.pub token_generator_ldap/jwt_key.pub
