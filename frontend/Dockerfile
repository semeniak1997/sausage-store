FROM node:16.20.0-alpine3.18 as builder
WORKDIR /usr/src/app
COPY . .
RUN npm install \
    && npm run build

FROM nginx:1.25.5-alpine3.19
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html
EXPOSE 80
