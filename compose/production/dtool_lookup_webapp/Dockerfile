FROM node:17

RUN apt-get update && apt-get install --yes nginx

#
# Checkout web GUI
#
RUN git clone --depth 1 https://github.com/jic-dtool/dtool-lookup-webapp.git /app

#
# Prepare application code
#
WORKDIR /app/dtool-lookup-webapp
COPY envs/production/dtool_lookup_webapp .env
RUN npm install
RUN npm run build

COPY compose/production/dtool_lookup_webapp/nginx.conf /etc/nginx/nginx.conf
