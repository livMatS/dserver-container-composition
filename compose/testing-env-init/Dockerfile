FROM jotelha/dtool:latest

COPY compose/testing-env-init/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod 755 /usr/bin/docker-entrypoint.sh

COPY compose/testing-env-init/copy_datasets.py /copy_datasets.py

ENTRYPOINT /usr/bin/docker-entrypoint.sh
