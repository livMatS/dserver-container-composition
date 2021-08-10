# dtool-lookup-server-container-composition

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/jotelha/dtool-lookup-server-container-composition/test)](https://github.com/jotelha/dtool-lookup-server-container-composition/actions?query=workflow%3Atest)

Copyright 2020, 2021, IMTEK Simulation, University of Freiburg

Author: Johannes Hoermann, johannes.hoermann@imtek.uni-freiburg.de

## Introduction

This container composition provides a working dtool lookp server ecosystem. It serves as testing framework
and template for provision. Components are

* `jotelha/dtool-lookup-server` [on dockerhub](https://hub.docker.com/r/jotelha/dtool-lookup-server), [on github](https://github.com/jotelha/dtool-lookup-server-container-image)
* `jotelha/dtool-lookup-client` [on dockerhub](https://hub.docker.com/r/jotelha/dtool-lookup-client), [on github](https://github.com/jotelha/dtool-lookup-client-container-image)
* `jotelha/dtool-token-generator-ldap`[on dockerhub](https://hub.docker.com/r/jotelha/dtool-token-generator-ldap), [on github](https://github.com/jotelha/dtool-token-generator-ldap-container-image)
* MongoDB [on dockerhub](https://hub.docker.com/_/mongo)
* Postgres [on dockerhub](https://hub.docker.com/_/postgres)
* `bitnami/openldap` [on dockerhub](https://hub.docker.com/r/bitnami/openldap/)
* `dperson/samba` [on dockerhub](https://hub.docker.com/r/dperson/samba)

## Quick start

**NOTE**: The following sections use `podman`. `docker` users will have to adapt
commands accordingly.

Run

```bash
cd keys && bash ./generate.sh && bash ./generate_jwt_key.sh
```

to generate tls/ssl and jwt keys, then run with

```bash
podman-compose up -d
```

## Usage

On launch, a test dataset is placed on the smb share. It might be necessary to manually refresh the index to
register this testing dataset after the first launch, i.e.

```bash
podman exec -it dtool-lookup-server-container-composition_dtool_lookup_server_1 /refresh_index
```

After pod up and images available, relaunch interactive session for manual
testing with

```bash
podman run -it --pod dtool-lookup-server-container-composition dtool-lookup-client bash
```

or run dtool commands directly, i.e. via

```console
$ podman run -it --pod dtool-lookup-server-container-composition jotelha/dtool-lookup-client dtool query '{}'
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

or

```console
$ podman run -it --pod dtool-lookup-server-container-composition jotelha/dtool-lookup-client dtool ls smb://test-share
simple_test_dataset
  smb://test-share/1a1f9fad-8589-413e-9602-5bbd66bfe675
```

From within ldap container, use

```bash
ldapsearch -p 1389 -h localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w adminpassword
```

for testing availability. From within sambaserver container, use

```bash
smbclient -U guest -W WORKGROUP //localhost/sambashare
```

to test availability.

## Secrets

TODO: Use proper docker secrets for providing keys.

## Testing

It is possible to run the github actions workflow in
`.github/workflows/test.yml` locally with the help of
[docker](https://www.docker.com/) and [act](https://github.com/nektos/act>).

After
[installing and configuring act](https://github.com/nektos/act#installation) run

```bash
act -P ubuntu-latest=catthehacker/ubuntu:full-latest -s GITHUB_TOKEN=$GITHUB_TOKEN -W .github/workflows/test.yml --bind
```

from within this repository. `$GITHUB_TOKEN` must hold a valid
[access token](https://github.com/settings/tokens). The user must be member of
the `docker` group. The `--bind` option avoids quirky permission errors by
running the test in the current directory. This will however result in the
local creation of two subdirectories `dtool-lookup-server-container-composition`
and `workflow` during testing, which may be removed with

```bash
rm -rf dtool-lookup-server-container-composition
sudo rm -rf workflow
```

eventually. All tests have been confirmed to work with the
`catthehacker/ubuntu:full-20.04` [runner](https://github.com/nektos/act#runners).
