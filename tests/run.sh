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

source env.testing.rc

docker-compose ${DOCKER_COMPOSE_OPTS} down --volumes --timeout 30

docker-compose ${DOCKER_COMPOSE_OPTS} pull
echo "docker image ls"
docker image ls

echo "generate jwt key"
cd keys && bash generate_jwt_key.sh && cd ..

docker-compose ${DOCKER_COMPOSE_OPTS} up -d

sleep 10 # TODO: mechanism to wait for containers to be ready

echo "docker container ls --all"
docker container ls --all

echo "docker volume ls"
docker volume ls

echo "docker images"
docker-compose ${DOCKER_COMPOSE_OPTS} images

echo "dserver log"
docker-compose ${DOCKER_COMPOSE_OPTS} logs dserver

echo "dtool lookup client log"
docker-compose ${DOCKER_COMPOSE_OPTS} logs dtool

bash tests/init.sh
