#!/bin/bash
echo "smbclient -U guest -c 'mkdir dtool' -N -W WORKGROUP //sambaserver/sambashare"
smbclient -U guest -c "mkdir dtool" -N -W WORKGROUP //sambaserver/sambashare

# place test datasets on storage infrastructure
echo "dtool cp tests/dtool/simple_test_dataset smb://test-share"
dtool cp /tests/dtool/simple_test_dataset smb://test-share

echo "dtool cp tests/dtool/simple_test_dataset s3://test-bucket"
dtool cp /tests/dtool/simple_test_dataset s3://test-bucket

if [ -d "/datasets" ]; then
  echo "dtool cp /datasets/* smb://test-share"
  python /copy_datasets.py
fi

echo "dtool ls smb://test-share"
dtool ls smb://test-share
echo "dtool ls s3://test-bucket"
dtool ls s3://test-bucket

echo "dtool query '{}'"
dtool query '{}'

exit 0
