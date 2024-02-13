#!/bin/bash
# configure alias for sminio host
mc config host add s3server http://s3server:9000 $(</run/secrets/access_key) $(</run/secrets/secret_key)
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
# create test user
mc admin user add s3server testuser_access_key testuser_secret_key
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
# assign privileges to user
mc admin policy set s3server readwrite user=testuser_access_key
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
# create bucket
mc mb s3server/test-bucket
# non-zero exit code might just mean the bucket exists already

# create event notifications: elasticsearch, WIP
# mc event add s3server/test-bucket arn:dserver:es:::localhost/notify/all --events "put"

# create event notifications: webhook
mc admin config set s3server/ notify_webhook:testbucket  endpoint="https://dserver:5000/webhook/notify"
mc admin service restart s3server
mc event add s3server/test-bucket arn:minio:sqs::testbucket:webhook --event put

# log config
mc admin config get s3server/ notify_webhook
mc event list s3server/test-bucket arn:minio:sqs::testbucket:webhook

exit 0
