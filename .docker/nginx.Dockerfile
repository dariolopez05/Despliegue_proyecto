FROM nginx:latest
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf
