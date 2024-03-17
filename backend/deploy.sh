#!/bin/bash

set -e
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-backend || true
sudo docker run --restart=on-failure:10 -d --name sausage-backend \
     --env SPRING_DATASOURCE_URL="jdbc:postgresql://${PSQL_HOST}:${PSQL_PORT}/${PSQL_DBNAME}" \
     --env SPRING_DATASOURCE_USERNAME="${PSQL_USER}" \
     --env SPRING_DATASOURCE_PASSWORD="${PSQL_PASS}" \
     --env SPRING_DATA_MONGODB_URI="mongodb://${MONGO_USER}:${MONGO_PASS}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DBNAME}?tls=true" \
     --env REPORT_PATH=/app/report \
     --env SPRING_FLYWAY_ENABLED=false \
     --network=sausage_network \
     "${CI_REGISTRY_IMAGE}"/sausage-backend:$CI_COMMIT_SHA 