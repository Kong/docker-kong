# Building Docker images that contain the Kong Gateway

Kong Software uses the [docker-kong github
repository](https://github.com/Kong/docker-kong/) to build Docker images that
contain the Kong Gateway. We will use
[docker-kong](https://github.com/Kong/docker-kong/) as a reference
implementation for describing how to build your own Docker images that contain the Kong
Gateway.

To build your Docker image, you will need to provide

1. A base Kong image of your choice
1. An entrypoint script that runs the Kong Gateway
1. A Dockerfile that installs the Kong Gateway from a location you specify

## Base image
You can use images derived from Ubuntu, Debian, AmazonLinux and RHEL; please see [kong/kong](https://registry.hub.docker.com/r/kong/kong) from Dockerhub.

## Entrypoint script

Get the [entrypoint
script](https://github.com/Kong/kong/blob/master/build/dockerfiles/entrypoint.sh)
from the [docker-kong github repository](https://github.com/Kong/docker-kong/) and put it in
directory where you are planning to run the command to build your Docker image.

## Create a Dockerfile to install Kong Gateway

### Write a Dockerfile to install the Kong Gateway package
Use the template below to create your Dockerfile. Angle brackets (`<>`) indicate
values that you need to provide. Comments that start "# Uncomment" indicate that
you need to uncomment lines relevant to your context.

The template is based upon the Dockerfiles in the [docker-kong github
repository](https://github.com/Kong/docker-kong/) and created manually. Check
the Dockerfiles for changes.

```
FROM <your-base-image>

ARG KONG_PREFIX=/usr/local/kong
ENV KONG_PREFIX $KONG_PREFIX

ARG EE_PORTS

RUN kong version

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

CMD ["kong", "docker-start"]
```

### Run the docker command

Run the command `docker build --no-cache -t <your-custom-image-name>
<path-for-built-image>` to build the docker image.
