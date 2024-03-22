FROM python:alpine3.18
COPY . /app
RUN wget -O  /usr/local/share/ca-certificates/YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && update-ca-certificates
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]
EXPOSE 8081