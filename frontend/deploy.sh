#!/bin/bash

set -e
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-frontend || true

while ! sudo docker ps | grep -q sausage-backend; do
    echo "Waiting for sausage-backend container to start..."
    sleep 5
done

sudo docker run --restart=on-failure:10 -d --name sausage-frontend \
     -v "/home/student/frontend/default.conf:/etc/nginx/conf.d/default.conf" \
     --network=sausage_network \
     -p 80:80 \
     "${CI_REGISTRY_IMAGE}"/sausage-frontend:$CI_COMMIT_SHA
