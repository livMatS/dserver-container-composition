ARG version=latest
FROM alpine:${version}

COPY compose/volume-init/init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]
