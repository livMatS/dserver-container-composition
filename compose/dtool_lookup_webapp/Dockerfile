FROM node:14

RUN apt-get update && apt-get install --yes nginx

#
# Checkout web GUI
#
RUN git clone --depth 1 https://github.com/jic-dtool/dtool-lookup-webapp.git /app

WORKDIR /app/dtool-lookup-webapp
COPY compose/dtool_lookup_webapp/custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod 755 /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["node"]
COPY compose/dtool_lookup_webapp/nginx.conf /etc/nginx/nginx.conf
