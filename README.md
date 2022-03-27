# dtool-lookup-server-container-composition

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/livMatS/dtool-lookup-server-container-composition/test)](https://github.com/livMatS/dtool-lookup-server-container-composition/actions?query=workflow%3Atest)

Copyright 2020, 2021 IMTEK Simulation, University of Freiburg, 2022 livMatS

Author: Johannes Hoermann, johannes.hoermann@imtek.uni-freiburg.de

## Introduction

This container composition provides a working dtool lookp server ecosystem. It serves as testing framework
and template for provision. Components are

* `livMatS/dtool-lookup-server` [on dockerhub](https://hub.docker.com/r/jotelha/dtool-lookup-server), [on github](https://github.com/livMatS/dtool-lookup-server-container-image)
* `livMatS/dtool-lookup-client` [on dockerhub](https://hub.docker.com/r/jotelha/dtool-lookup-client), [on github](https://github.com/livMatS/dtool-lookup-client-container-image)
* `livMatS/dtool-token-generator-ldap`[on dockerhub](https://hub.docker.com/r/jotelha/dtool-token-generator-ldap), [on github](https://github.com/livMatS/dtool-token-generator-ldap-container-image)
* [`livmats/dtool-lookup-webapp`](https://github.com/livmats/dtool-lookup-webapp), fork of [`jic-dtool/dtool-lookup-webapp`](https://github.com/jic-dtool/dtool-lookup-webapp)
* MongoDB [on dockerhub](https://hub.docker.com/_/mongo)
* Postgres [on dockerhub](https://hub.docker.com/_/postgres)
* `bitnami/openldap` [on dockerhub](https://hub.docker.com/r/bitnami/openldap/)
* `dperson/samba` [on dockerhub](https://hub.docker.com/r/dperson/samba)
* `minio/minio` [on dockerhub](https://hub.docker.com/r/minio/minio)

## Quick start

Run

```bash
cd keys && bash ./generate_jwt_key.sh
```

to generate tls/ssl and jwt keys, then source the preconfigured env file

```bash
source env.testing.rc
```

and run with

```bash
docker-compose ${DOCKER_COMPOSE_OPTS} up -d
```

to bring up a fully functional dtool ecosystem composition.

To initialize this server composition with test datasets on smb share and s3 bucket and index those once, run

```bash
bash tests/init.sh
```

## Stacking docker-compose files

Several combinable docker-compose files are available as samples. 
These are stacked and merged on the command line in the manner of

```bash
docker-compose -f docker-compose.yml -f docker-compose.default-envs.yml -f docker-compose.alt-ports.yml up -d
```

Inspect the `env*rc` files to understand how to use them. 


```bash
source env.testing.alt-ports.rc
docker-compose ${DOCKER_COMPOSE_OPTS} up -d
```

will set up the docker-compose command line options accordingly in `${DOCKER_COMPOSE_OPTS}` and bring up a server on alternative ports.
Make sure execute all docker-compose commands on the composition with the same set of parameters.

To see the resulting compose configuration, use

```bash
docker-compose ${DOCKER_COMPOSE_OPTS} config
```

## Pinned versions

Two docker-compose override files are used for pinning versions on images. These versions are used in CI workflows. 
Latest images used per default may not work. For pinning all images to these sversions, use

docker-compose -f docker-compose.yml -f docker-compose.versions.yml \
               -f docker-compose.default-envs.yml -f docker-compose.default-ports.yml \
               -f docker-compose.testing.yml -f docker-compose.testing.versions.yml up -d

## Usage

Per default, this composition provides self-signed SSL certificates.
To access the dtool-lookup-webapp within this testing configuration via your browser,
add the generated certificates as security exceptions to your browser.
You will have to retrieve the certificates for the web app, the lookup server and the token genrator.
If running locally in default configuration, retrieve the certificates from

    https://localhost:5000
    https://localhost:5001/token
    https://localhost:80


**NOTE**: The following sections use `podman`. `docker` users will have to adapt
commands accordingly.


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

## Maintenance

To update `docker-compose` specs version, use

    grep -l "version: '2'" docker-compose.* | xargs sed -i "s/version: '2'/version: '3.8'/g"

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
