#!/bin/bash -x
#
# This snippet is meant for running tests quickly locally and may be outdated.
# The proper testing workflow resides within .github/workflows/test.yml
#
# Run test script from within repository root i.e. via
#
#   export DOCKER_COMPOSE_OPTS="-f docker-compose.yml -f docker-compose.external-envs.yml -f docker-compose.alt-ports.yml -f docker-compose.testing.yml"
#   bash tests/run.sh
#
# Docker is required.
#
set -euxo pipefail

DOCKER_COMPOSE_OPTS=${DOCKER_COMPOSE_OPTS:-"-f docker-compose.yml -f docker-compose.default-envs.yml -f docker-compose.default-ports.yml -f docker-compose.testing.yml"}

docker-compose ${DOCKER_COMPOSE_OPTS} down --volumes --timeout 30

docker-compose ${DOCKER_COMPOSE_OPTS} pull
echo "docker image ls"
docker image ls

echo "generate jwt key"
cd keys && bash generate_jwt_key.sh && cd ..

docker-compose ${DOCKER_COMPOSE_OPTS} -p dtool-lookup-server-container-composition up -d

sleep 10 # TODO: mechanism to wait for containers to be ready

echo "docker container ls --all"
docker container ls --all

echo "docker volume ls"
docker volume ls

echo "docker images"
docker-compose ${DOCKER_COMPOSE_OPTS} images

echo "dtool lookup server log"
docker-compose ${DOCKER_COMPOSE_OPTS} logs dtool_lookup_server

echo "dtool lookup client log"
docker-compose ${DOCKER_COMPOSE_OPTS} logs dtool_lookup_client

# create dtool directory on samba share
echo "smbclient -U guest -c "mkdir dtool" -N -W WORKGROUP //sambaserver/sambashare"
docker-compose ${DOCKER_COMPOSE_OPTS} run --entrypoint smbclient dtool_lookup_client -U guest -c "mkdir dtool" -N -W WORKGROUP //sambaserver/sambashare

# place test datasets on storage infrastructure
echo "dtool cp tests/dtool/simple_test_dataset smb://test-share"
docker-compose ${DOCKER_COMPOSE_OPTS} run -v $(pwd)/tests:/tests dtool_lookup_client cp /tests/dtool/simple_test_dataset smb://test-share

echo "dtool cp tests/dtool/simple_test_dataset s3://test-bucket"
docker-compose ${DOCKER_COMPOSE_OPTS} run -v $(pwd)/tests:/tests dtool_lookup_client cp /tests/dtool/simple_test_dataset s3://test-bucket

echo "dtool ls smb://test-share"
docker-compose ${DOCKER_COMPOSE_OPTS} run dtool_lookup_client ls smb://test-share

echo "dtool ls s3://test-bucket"
docker-compose ${DOCKER_COMPOSE_OPTS} run dtool_lookup_client ls s3://test-bucket

echo "explicitly re-evoke dataset indexing"
docker-compose ${DOCKER_COMPOSE_OPTS} exec -T dtool_lookup_server /refresh_index

echo "dtool query '{}'"
docker-compose ${DOCKER_COMPOSE_OPTS} run dtool_lookup_client query '{}'

# echo "docker-compose down --volumes"
# docker-compose down --volumes --timeout 30
