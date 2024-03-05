#!/bin/bash

if [ -z "${NEXUS_REPO_USER}" ] || [ -z "${NEXUS_REPO_PASS}" ] || [ -z "${NEXUS_REPO_URL}" ] || [ -z "${NEXUS_BACKEND}" ] || [ -z "${VERSION}" ]; then
    echo "Error: Some variables for artifacts are not defined"
    exit 1
fi

if [ -z "${PSQL_HOST}" ] || [ -z "${PSQL_USER}" ] || [ -z "${PSQL_PASS}" ] || [ -z "${PSQL_PORT}" ] || [ -z "${PSQL_DBNAME}" ]; then
    echo "Error: Some variables for PostgreSQL are not defined"
    exit 1
fi

if [ -z "${MONGO_HOST}" ] || [ -z "${MONGO_USER}" ] || [ -z "${MONGO_PASS}" ] || [ -z "${MONGO_PORT}" ] || [ -z "${MONGO_DBNAME}" ]; then
    echo "Error: Some variables for MongoDB are not defined"
    exit 1
fi

if [ -z "${JAVA_KEYSTORE_PASS}" ]; then
    echo "Error: Some variables for JKS are not defined"
    exit 1
fi

set -e

backend_dest="/opt/sausage-store/bin"
artifacts_dest="$backend_dest/artifacts"
services_dest="$backend_dest/backend_services"
systemd_dest="/etc/systemd/system"
creds_dest="/root/creds"
certs_store="$backend_dest/certs"

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

if [ ! -d "$creds_dest" ]; then
    sudo mkdir -p "$creds_dest"
    echo "Warning: created $creds_dest"
fi

sudo echo -e "PSQL_HOST=\"${PSQL_HOST}"\" \
    \\nPSQL_USER=\"${PSQL_USER}"\"\
    \\nPSQL_PASS=\"${PSQL_PASS}"\" \
    \\nPSQL_PORT=\"${PSQL_PORT}\" \
    \\nPSQL_DBNAME=\"${PSQL_DBNAME}\" \
    > ./psql_creds

sudo cp -f ./psql_creds $creds_dest/.psql_creds
sudo rm -f ./psql_creds

sudo echo -e "MONGO_HOST=\"${MONGO_HOST}"\" \
    \\nMONGO_USER=\"${MONGO_USER}"\"\
    \\nMONGO_PASS=\"${MONGO_PASS}"\" \
    \\nMONGO_PORT=\"${MONGO_PORT}\" \
    \\nMONGO_DBNAME=\"${MONGO_DBNAME}\" \
    > ./mongodb_creds

sudo cp -f ./mongodb_creds $creds_dest/.mongodb_creds
sudo rm -f ./mongodb_creds

sudo echo -e "JAVA_KEYSTORE_PASS=\"${JAVA_KEYSTORE_PASS}"\" \ > ./jks_creds
sudo cp -f ./jks_creds $creds_dest/.jks_creds
sudo rm -f ./jks_creds

if ! curl --fail -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o "sausage-store-${VERSION}.jar" "${NEXUS_REPO_URL}/${NEXUS_BACKEND}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar"; then
    echo "Error: Download artifact failed"
    exit 1
fi

sudo mv sausage-store-${VERSION}.jar $artifacts_dest/sausage-store-${VERSION}.jar
sudo ln -sf $artifacts_dest/sausage-store-${VERSION}.jar $backend_dest/sausage-store.jar
sudo chown backend:backend $artifacts_dest/sausage-store-${VERSION}.jar 

if ! curl --fail -o YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem ; then
    echo "Error: Download CA.pem failed"
    exit 1
fi

if [ ! -d "$certs_store" ]; then
    sudo mkdir -p "$certs_store"
    sudo chown -R backend:backend "$certs_store"
    echo "Warning: created $certs_store"
fi

sudo /usr/lib/jvm/java-16-openjdk-amd64/bin/keytool -importcert -alias yandex \
     -file YandexInternalRootCA.crt -keystore $certs_store/YATrustStore \
     -storepass ${JAVA_KEYSTORE_PASS} -noprompt||true

sudo mv -f YandexInternalRootCA.crt $certs_store/YandexInternalRootCA.crt
sudo chown backend:backend $certs_store/YandexInternalRootCA.crt
sudo chmod 600 $certs_store/YandexInternalRootCA.crt

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

