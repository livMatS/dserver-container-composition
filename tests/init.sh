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
