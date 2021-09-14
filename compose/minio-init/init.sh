#!/bin/bash
mc config host add s3server http://s3server:9000 $(</run/secrets/access_key) $(</run/secrets/secret_key)
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
mc admin user add s3server testuser_access_key testuser_secret_key
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
mc mb s3server/test-bucket
# non-zero exit code might just mean the bucket exists already
exit 0
