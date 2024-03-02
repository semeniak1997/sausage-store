#! /bin/bash
set -xe
sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service


sudo echo -e "PSQL_HOST=${PSQL_HOST} \
    \nPSQL_USER=${PSQL_USER} \
    \nPSQL_PASSWORD=${PSQL_PASSWORD} \
    \nPSQL_PORT=${PSQL_PORT} \
    \nPSQL_DBNAME=${PSQL_DBNAME}" \
    > ./db_creds
sudo cp -f ./db_creds /root/.db_creds
sudo rm -f ./db_creds




sudo rm -rf /home/student/sausage-store.jar
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/${NEXUS_BACKEND}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
sudo cp -rf ./sausage-store.jar /opt/sausage-store/bin/sausage-store.jar

wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
    -O root.crt

sudo /usr/lib/jvm/java-16-openjdk-amd64/bin/keytool -import -alias YandexCA \
    -file root.crt \
    -keystore /etc/ssl/certs/java/cacerts \
    -storepass ${JAVA_KEYSTORE_PASS} -noprompt||true

rm -f root.crt


sudo systemctl daemon-reload
sudo systemctl enable sausage-store-backend
sudo systemctl restart sausage-store-backend
