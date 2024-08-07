# dserver-container-composition

[![dtool](data/icons/22x22/dtool_logo.png)](https://dtoolcore.readthedocs.io) [![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/livMatS/dserver-container-composition/test.yml?branch=master)](https://github.com/livMatS/dserver-container-composition/actions?query=workflow%3Atest)

Copyright 2020, 2021 IMTEK Simulation, University of Freiburg, 2022 livMatS

Author: Johannes Hoermann, johannes.hoermann@imtek.uni-freiburg.de

## Introduction

This container composition provides a working dtool lookup server ecosystem. It serves as testing framework
and template for provision. Components are

* `jotelha/dserver` [on dockerhub](https://hub.docker.com/r/jotelha/dserver), [on github](https://github.com/livMatS/dserver-container-image)
* `jotelha/dtool` [on dockerhub](https://hub.docker.com/r/jotelha/dtool), [on github](https://github.com/livMatS/dtool-container-image)
* `jotelha/dtool-token-generator-ldap`[on dockerhub](https://hub.docker.com/r/jotelha/dtool-token-generator-ldap), [on github](https://github.com/livMatS/dtool-token-generator-ldap-container-image)
* `jotelha/dtool-config-generator` [on dockerhub](https://hub.docker.com/r/jotelha/dtool-config-generator), [on github](https://github.com/livMatS/dtool-config-generator-container-image)
* [`jic-dtool/dtool-lookup-webapp`](https://github.com/jic-dtool/dtool-lookup-webapp)
* MongoDB [on dockerhub](https://hub.docker.com/_/mongo)
* Postgres [on dockerhub](https://hub.docker.com/_/postgres)
* `bitnami/openldap` [on dockerhub](https://hub.docker.com/r/bitnami/openldap/)
* `dperson/samba` [on dockerhub](https://hub.docker.com/r/dperson/samba)
* `minio/minio` [on dockerhub](https://hub.docker.com/r/minio/minio)
* `nginx` [on dockerhub](https://hub.docker.com/_/nginx)

## Quick start

Run

```bash
bash maintenance/replace_hostname.sh localhost
```

from within repository root to replace the placeholder `my.domain.placeholder`
with `localhost` wherever it occurs. Next, run

```bash
cd keys && bash ./generate_jwt_key.sh
```

to generate tls/ssl and jwt keys, then source the hidden file

```
source .env
```

to set a few general environment variables which are referenced across the 
YAML compose files. Importantly, this will set `$HOSTNAME` to `localhost`.

Afterwards, source the preconfigured env file

```bash
source env.testing.rc
```

and to set `$DOCKER_COMPOSE_OPTS` to a stack of YAML compose files and run with

```bash
docker compose ${DOCKER_COMPOSE_OPTS} up -d
```

to bring up a fully functional dtool ecosystem composition.

The default configuration exposes several services behind a reverse proxy. 
If the composition runs on `localhost`, then

* `/lookup` routes expose the lookup server
* `/token` exposes the token generator
* `/config` routes might expose the config generator,
  but not for the testing composition launched here
* `/` directly exposes the lookup server webapp

## Composition-wide environment variables

Use a docker compose `.env` file with content

```
# ssl cerificates
ADMINMAIL=admin@dtool-lookup.server
HOSTNAME=my.domain.placeholder

EXTERNAL_HTTP_PORT=80
EXTERNAL_HTTPS_PORT=443
```

to override defaults for site address and ports.

## Hard-coded domain name

Run

```bash
bash maintenance/replace_hostname.sh $HOSTNAME
```

to replace the `my.domain.placeholder` string hard-coded within several files
by `$HOSTNAME` (or any other domain).

## Stacking docker-compose files

Several combinable docker-compose files are available as samples. 
These are stacked and merged on the command line in the manner of

```bash
docker compose -f docker-compose.yml -f docker-compose.default-envs.yml -f docker-compose.alt-ports.yml up -d
```

Inspect the `env*rc` files to understand how to use them. 


```bash
source env.testing.alt-ports.rc
docker compose ${DOCKER_COMPOSE_OPTS} up -d
```

will set up the docker-compose command line options accordingly in `${DOCKER_COMPOSE_OPTS}` and bring up a server on alternative ports.
Make sure execute all docker-compose commands on the composition with the same set of parameters.

To see the resulting compose configuration, use

```bash
docker compose ${DOCKER_COMPOSE_OPTS} config
```

## Pinned versions

Two docker-compose override files are used for pinning versions on images. These versions are used in CI workflows. 
Latest images used per default may not work. For pinning all images to these sversions, use

    docker compose -f docker-compose.yml -f docker-compose.versions.yml \
                   -f docker-compose.default-envs.yml -f docker-compose.default-ports.yml \
                   -f docker-compose.testing.yml -f docker-compose.testing.versions.yml up -d

## TLS/SSL certificates

This compositon may use `acme.sh` to install certificates. These are expected 
to reside within `${HOME}/acme.sh` on the host machine.

Use the `neilpang/acme.sh:latest` docker image and commands like

```bash
# get help
docker run neilpang/acme.sh:latest acme.sh --help

# issue testing certificates for first time, this happens via Let's Encrypt
mkdir -p $HOME/acme.sh
docker run -v "$HOME/acme.sh:/acme.sh" -p 80:80 --rm neilpang/acme.sh:latest \
  acme.sh --issue -d livmats-data.vm.uni-freiburg.de --standalone --staging

# then replace testing certificates with proper ones,
docker run -v "$HOME/acme.sh:/acme.sh" --rm neilpang/acme.sh:latest \
  acme.sh --register-account -m data@livmats-uni-freiburg.de
docker run -v "$HOME/acme.sh:/acme.sh" -p 80:80 --rm neilpang/acme.sh:latest \
  acme.sh --issue -d livmats-data.vm.uni-freiburg.de --standalone --force
```

to issue and store certificates. Then, use 

    source env.testing.valid-certificates.alt-ports.rc
    docker compose ${DOCKER_COMPOSE_OPTS} up -d

to install these certificates into the composition at startup.
Inspect `env.testing.valid-certificates.alt-ports.rc` and `docker-compose.acme.yml`
and adapt them as needed.

## Usage

Per default, this composition provides self-signed SSL certificates.
To access the dtool-lookup-webapp within this testing configuration via your browser,
add the generated certificates as security exceptions to your browser.
You will have to retrieve the certificates for the web app, the lookup server and the token genrator.
If running locally in default configuration, retrieve the certificates from

    https://localhost:5000
    https://localhost:5001/token
    https://localhost:80

On launch, a test dataset is placed on the smb share. It might be necessary to manually refresh the index to
register this testing dataset after the first launch, i.e.

```bash
docker compose ${DOCKER_COMPOSE_OPTS} exec -it dserver /refresh_index
```

After pod up and images available, relaunch interactive session for manual
testing with

```bash
docker compose ${DOCKER_COMPOSE_OPTS} run -it --entrypoint bash dtool
```

or run dtool commands directly, i.e. via

```console
$ docker compose ${DOCKER_COMPOSE_OPTS} run -it dtool search 'Test'
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

```console
$ docker compose ${DOCKER_COMPOSE_OPTS} run -it dtool ls smb://test-share
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
local creation of two subdirectories `dserver-container-composition`
and `workflow` during testing, which may be removed with

```bash
rm -rf dserver-container-composition
sudo rm -rf workflow
```

eventually. All tests have been confirmed to work with the
`catthehacker/ubuntu:full-20.04` [runner](https://github.com/nektos/act#runners).
