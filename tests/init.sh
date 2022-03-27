#!/bin/bash
#
# This snippet initializes the server composition. Make sure to set the correct DOCKER_COMPOSE_OPTS before running.

DOCKER_COMPOSE_OPTS=${DOCKER_COMPOSE_OPTS:-"-p dtool-lookup- server \
                                           -f docker-compose.yml \
                                           -f docker-compose.versions.yml \
                                           -f docker-compose.default-envs.yml \
                                           -f docker-compose.default-ports.yml \
                                           -f docker-compose.testing.yml \
                                           -f docker-compose.testing.versions.yml"}

echo "explicitly re-evoke dataset indexing"
docker compose ${DOCKER_COMPOSE_OPTS} exec -T dtool_lookup_server /refresh_index
echo "dtool query '{}'"
docker compose ${DOCKER_COMPOSE_OPTS} run dtool_lookup_client query '{}'
