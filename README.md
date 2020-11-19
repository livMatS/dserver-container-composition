# Quick start

Run

    cd keys && bash ./generate.sh && bash ./generate_jwt_key.sh

to generate tls/ssl and jwt keys, then run with

    podman-compose up -d


# Usage

On launch, a test dataset is placed on the smb share.

After pod up and images available, relaunch interactive session for manual
testing with

    podman run -it --pod dtool-lookup-server-container-composition dtool-lookup-client bash

or run dtool commands directly, i.e. via

```console
$ podman run -it --pod dtool-lookup-server-container-composition dtool-lookup-client dtool query '{}'
[
  {
    "base_uri": "smb://test-share",
    "created_at": 1604860720.736,
    "creator_username": "jotelha",
    "dtoolcore_version": "3.17.0",
    "frozen_at": 1605786853.623,
    "name": "simple_test_dataset",
    "tags": [],
    "type": "dataset",
    "uri": "smb://test-share/1a1f9fad-8589-413e-9602-5bbd66bfe675",
    "uuid": "1a1f9fad-8589-413e-9602-5bbd66bfe675"
  }
]
```

From within ldap container, use

    ldapsearch -p 1389 -h localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w adminpassword

for testing availability. From within sambaserver container, use

    smbclient -U guest -W WORKGROUP //localhost/sambashare

to test availability.
