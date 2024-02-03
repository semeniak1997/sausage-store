#! /bin/bash
set -xe

sudo cp -rf sausage-store.conf /etc/nginx/sites-enabled/sausage-store.conf
sudo ln -sf /etc/nginx/sites-enabled/sausage-store.conf /etc/nginx/sites-enabled/sausage-store.conf 

sudo rm -rf /home/student/sausage-store-front.tar.gz

cd /home/student
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-front.tar.gz ${NEXUS_REPO_URL}/${NEXUS_FRONTEND}/${VERSION}/sausage-store-${VERSION}.tar.gz

sudo rm -rf /home/student/frontend
tar -zxf ./sausage-store-front.tar.gz ||true
sudo chown -R www-data:www-data ./frontend
sudo mkdir -p /opt/sausage-store/static/dist/frontend
sudo cp -rf ./frontend/* /opt/sausage-store/static/dist/frontend

sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl restart nginx
