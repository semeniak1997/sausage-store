#!/bin/bash

if [ -z "${NEXUS_REPO_USER}" ] || [ -z "${NEXUS_REPO_PASS}" ] || [ -z "${NEXUS_REPO_URL}" ] || [ -z "${NEXUS_BACKEND}" ] || [ -z "${VERSION}" ]; then
    echo "Error: Some variables for artifacts are not defined"
    exit 1
fi

if [ -z "${PSQL_HOST}" ] || [ -z "${PSQL_USER}" ] || [ -z "${PSQL_PASS}" ] || [ -z "${PSQL_PORT}" ] || [ -z "${PSQL_DBNAME}" ] || [ -z "${JAVA_KEYSTORE_PASS}" ] ; then
    echo "Error: Some variables for PostgreSQL are not defined"
    exit 1
fi

set -e

backend_dest="/opt/sausage-store/bin"
artifacts_dest="$backend_dest/artifacts"
services_dest="$backend_dest/backend_services"
systemd_dest="/etc/systemd/system"

if [ ! -d "$backend_dest" ]; then
    sudo mkdir -p "$backend_dest"
    sudo chown -R backend:backend "$backend_dest"
    echo "Warning: created $backend_dest"
fi

if [ ! -d "$artifacts_dest" ]; then
    sudo mkdir -p "$artifacts_dest"
    sudo chown -R backend:backend "$artifacts_dest"
    echo "Warning: created $artifacts_dest"
fi

if [ ! -d "$services_dest" ]; then
    sudo mkdir -p "$services_dest"
    sudo chown -R backend:backend "$services_dest"
    echo "Warning: created $services_dest"
fi

sudo mv sausage-store-backend.service $services_dest/sausage-store-backend-${VERSION}.service
sudo ln -f $services_dest/sausage-store-backend-${VERSION}.service $services_dest/sausage-store-backend.service

sudo ln -sf $services_dest/sausage-store-backend.service $systemd_dest/sausage-store-backend.service

sudo echo -e "PSQL_HOST=\"${PSQL_HOST}"\" \
    \\nPSQL_USER=\"${PSQL_USER}"\"\
    \\nPSQL_PASS=\"${PSQL_PASS}"\" \
    \\nPSQL_PORT=\"${PSQL_PORT}\" \
    \\nPSQL_DBNAME=\"${PSQL_DBNAME}\" \
    > ./db_creds

sudo cp -f ./db_creds /root/.db_creds
sudo rm -f ./db_creds

if ! curl --fail -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o "sausage-store-${VERSION}.jar" "${NEXUS_REPO_URL}/${NEXUS_BACKEND}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar"; then
    echo "Error: Download artifact failed"
    exit 1
fi

sudo mv sausage-store-${VERSION}.jar $artifacts_dest/sausage-store-${VERSION}.jar
sudo ln -sf $artifacts_dest/sausage-store-${VERSION}.jar $backend_dest/sausage-store.jar
sudo chown backend:backend $artifacts_dest/sausage-store-${VERSION}.jar 

#wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O root.crt

#sudo /usr/lib/jvm/java-16-openjdk-amd64/bin/keytool -import -alias YandexCA \
#    -file root.crt \
#    -keystore /etc/ssl/certs/java/cacerts \
#    -storepass ${JAVA_KEYSTORE_PASS} -noprompt||true

#rm -f root.crt

sudo systemctl daemon-reload
sudo systemctl enable sausage-store-backend.service
sudo systemctl restart sausage-store-backend.service

sudo systemctl status sausage-store-backend.service
status_code_backend=$?
if [ $status_code_backend -eq 0 ]; then
  echo "Service is running."
else
  echo "Service failed with code: $status_code_backend"
  exit 1
fi

