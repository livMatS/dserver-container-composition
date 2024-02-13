#!/bin/bash
#
# This snippet initializes the server composition. Make sure to set the correct DOCKER_COMPOSE_OPTS before running.

source env.testing.rc

echo "explicitly re-evoke dataset indexing"
docker compose ${DOCKER_COMPOSE_OPTS} exec -T dserver /refresh_index
echo "dtool query '{}'"
docker compose ${DOCKER_COMPOSE_OPTS} run dtool_lookup_client query '{}'
