podman login docker.io
podman push dtool-lookup-server docker://docker.io/jotelha/dtool-lookup-server:latest
podman push dtool-lookup-client docker://docker.io/jotelha/dtool-lookup-client:latest
podman push dtool-token-generator-ldap docker://docker.io/jotelha/dtool-token-generator-ldap:latest

