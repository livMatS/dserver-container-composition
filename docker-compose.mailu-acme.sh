---
services:

  front:
    depends_on:
      acme-mailu:
        condition: service_completed_successfully

  # failed to modify the default storage location of certs  in mailu, hence just use another volume with different structure her
  acme-mailu:
    image: neilpang/acme.sh:latest
    restart: "no"
    command: >-
      acme.sh --install-cert -d ${DOMAIN}
              --cert-file      /certs/cert.pem
              --key-file       /certs/key.pem
              --ca-file        /certs/ca.pem
              --fullchain-file /certs/full-chain.pem
    volumes:
      - type: volume
        source: cert_data_mailu
        target: /certs
      - type: bind
        source: $HOME/acme.sh
        target: /acme.sh
        read_only: true
