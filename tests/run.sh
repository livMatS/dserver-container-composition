#!/bin/bash -x
#
# This snippet is meant for running tests quickly locally and may be outdated.
# The proper testing workflow resides within .github/workflows/test.yml
#
# Run test script from within repository root via
#
#   bash tests/run.sh
#
# Docker is required.
#
set -euxo pipefail
docker-compose down --volumes --timeout 30

docker-compose pull
echo "docker image ls"
docker image ls

echo "generate certs and keys"
cd keys
bash generate.sh
bash generate_jwt_key.sh
cd ..

docker-compose -p dtool-lookup-server-container-composition up -d

sleep 10 # TODO: mechanism to wait for containers to be ready

echo "docker container ls --all"
docker container ls --all

echo "docker volume ls"
docker volume ls

echo "docker images"
docker-compose images

echo "dtool lookup server log"
docker-compose logs dtool_lookup_server

echo "dtool lookup client log"
docker-compose logs dtool_lookup_client

# create dtool directory on samba share
echo "smbclient -U guest -c "mkdir dtool" -N -W WORKGROUP //sambaserver/sambashare"
docker-compose run --entrypoint smbclient dtool_lookup_client -U guest -c "mkdir dtool" -N -W WORKGROUP //sambaserver/sambashare

# place test datasets on storage infrastructure
echo "dtool cp tests/dtool/simple_test_dataset smb://test-share"
docker-compose run -v $(pwd)/tests:/tests dtool_lookup_client cp /tests/dtool/simple_test_dataset smb://test-share

echo "dtool cp tests/dtool/simple_test_dataset s3://test-bucket"
docker-compose run -v $(pwd)/tests:/tests dtool_lookup_client cp /tests/dtool/simple_test_dataset s3://test-bucket

echo "dtool ls smb://test-share"
docker-compose run dtool_lookup_client ls smb://test-share

echo "dtool ls s3://test-bucket"
docker-compose run dtool_lookup_client ls s3://test-bucket

echo "explicitly re-evoke dataset indexing"
docker-compose exec -T dtool_lookup_server /refresh_index

echo "dtool query '{}'"
docker-compose run dtool_lookup_client query '{}'

# echo "docker-compose down --volumes"
# docker-compose down --volumes --timeout 30
