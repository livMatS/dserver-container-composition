FROM jotelha/dserver-client:latest

COPY compose/testing-env-init/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod 755 /usr/bin/docker-entrypoint.sh
ENTRYPOINT /usr/bin/docker-entrypoint.sh
