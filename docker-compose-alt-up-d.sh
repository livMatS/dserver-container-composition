#!/bin/bash
docker-compose -f docker-compose.yml -f docker-compose.external-envs.yml -f docker-compose.alt-ports.yml up -d