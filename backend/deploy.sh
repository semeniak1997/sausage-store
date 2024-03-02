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

sudo mv sausage-store-backend.service /opt/sausage-store/bin/backend_services/sausage-store-backend-${VERSION}.service
sudo ln -f /opt/sausage-store/bin/backend_services/sausage-store-backend-${VERSION}.service /etc/systemd/system/sausage-store-backend.service

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


sudo mv ./sausage-store-${VERSION}.jar /opt/sausage-store/bin/artifacts/sausage-store-${VERSION}.jar
sudo ln -f /opt/sausage-store/bin/artifacts/sausage-store-${VERSION}.jar /opt/sausage-store/bin/sausage-store.jar

wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O root.crt

sudo /usr/lib/jvm/java-16-openjdk-amd64/bin/keytool -import -alias YandexCA \
    -file root.crt \
    -keystore /etc/ssl/certs/java/cacerts \
    -storepass ${JAVA_KEYSTORE_PASS} -noprompt||true

rm -f root.crt

sudo systemctl daemon-reload
sudo systemctl enable sausage-store-backend
sudo systemctl restart sausage-store-backend


