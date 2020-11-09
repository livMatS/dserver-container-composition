FROM python:3.8-slim

#
# Checkout token generator
#
RUN apt-get --yes update && \
    apt-get --no-install-recommends --yes install git && \
    git clone https://github.com/jic-dtool/token-generator-ldap.git /app && \
    pip install -r /app/requirements.txt && \
    pip install gunicorn && \
    apt-get remove --purge --autoremove -y git && \
    rm -rf /var/lib/apt/lists/*

#
# Prepare application code
#
WORKDIR /app
COPY compose/production/token_generator_ldap/wsgi.py .
COPY compose/production/token_generator_ldap/production.cfg .

COPY compose/production/token_generator_ldap/start /start
RUN sed -i 's/\r//' /start
RUN chmod +x /start
