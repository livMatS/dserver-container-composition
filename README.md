# Quick start

Run

    cd keys && bash ./generate.sh && bash ./generate_jwt_key.sh

to generate tls/ssl and jwt keys, then build and run with

    podman-compose up -d


# Usage

After pod up and images available, relaunch interactive session for manual
testing with

    podman run -it --pod dtool-lookup-server-container-composition localhost/production_dtool_lookup_client bash

From within ldap container, use

    ldapsearch -p 1389 -h localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w adminpassword

for testing availability. From within sambaserver container, use

    smbclient -U guest -W WORKGROUP //localhost/sambashare

to test availability.
