# a minimal Nginx container including ContainerPilot and a simple virtulhost config
FROM nginx:stable-alpine

# add ContainerPilot configuration and onChange handler
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8000 8443 8001
