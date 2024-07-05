#!/bin/bash
# configure alias for sminio host
echo "mc config host add s3server http://s3server:9000 xxx xxx"
mc config host add s3server http://s3server:9000 $(</run/secrets/access_key) $(</run/secrets/secret_key)
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
# create test user
echo "mc admin user add s3server testuser_access_key testuser_secret_key"
mc admin user add s3server testuser_access_key testuser_secret_key
ret=$?
if [ $ret -ne 0 ]; then
    exit $ret
fi
# assign privileges to user
echo "mc admin policy attach s3server readwrite --user=testuser_access_key"
mc admin policy attach s3server readwrite --user=testuser_access_key
# non-zero exit code might just mean the specified policy change is already in effect.

# create bucket
echo "mc mb s3server/test-bucket"
mc mb s3server/test-bucket
# non-zero exit code might just mean the bucket exists already

# set public accessibility on bucket
echo "mc anonymous set public s3server/test-bucket"
mc anonymous set public s3server/test-bucket

# set quota on bucket
echo "mc quota set s3server/test-bucket --size 1GB"
mc quota set s3server/test-bucket --size 1GB

# create event notifications: elasticsearch, WIP
# mc event add s3server/test-bucket arn:dserver:es:::localhost/notify/all --events "put"

# create event notifications: webhook
echo "mc admin config set s3server/ notify_webhook:testbucket  endpoint="https://web/lookup/webhook/notify""
mc admin config set s3server/ notify_webhook:testbucket  endpoint="https://web/lookup/webhook/notify"
echo "mc admin service restart s3server"
mc admin service restart s3server
echo "mc event add s3server/test-bucket arn:minio:sqs::testbucket:webhook --event put"
mc event add s3server/test-bucket arn:minio:sqs::testbucket:webhook --event put

# log config
echo "mc admin config get s3server/ notify_webhook"
mc admin config get s3server/ notify_webhook
echo "mc event list s3server/test-bucket arn:minio:sqs::testbucket:webhook"
mc event list s3server/test-bucket arn:minio:sqs::testbucket:webhook

exit 0
