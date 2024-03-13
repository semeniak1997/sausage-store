#! /bin/bash

set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-frontend || true

while ! sudo docker ps | grep -q sausage-backend; do
    echo "Waiting for sausage-backend container to start..."
    sleep 5
done

sudo docker run --rm -d --name sausage-frontend \
     -v "/tmp/${CI_PROJECT_DIR}/default.conf:/etc/nginx/conf.d/default.conf" \
     --network=sausage_network \
     -p 80:80 \
     "${CI_REGISTRY_IMAGE}"/sausage-frontend:latest 
