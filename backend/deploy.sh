#! /bin/bash
set -xe
sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
sudo rm -rf /home/${DEV_HOST}/sausage-store.jar
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/${NEXUS_BACKEND}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
sudo cp -rf ./sausage-store.jar /opt/sausage-store/bin/sausage-store.jar

sudo systemctl daemon-reload
sudo systemctl enable sausage-store-backend
sudo systemctl restart sausage-store-backend
