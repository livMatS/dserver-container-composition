ARG version=latest
FROM minio/mc:${version}

COPY compose/minio-init/init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]
