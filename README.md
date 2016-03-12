# Kong in Docker

This is the official Docker image for [Kong][kong-site-url].

# Supported tags and respective `Dockerfile` links

- `latest` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.7.0/Dockerfile))*
- `0.7.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.7.0/Dockerfile))*
- `0.6.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.6.1/Dockerfile))*
- `0.6.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.6.0/Dockerfile))*
- `0.5.4` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.4/Dockerfile))*
- `0.5.3` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.3/Dockerfile))*
- `0.5.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.2/Dockerfile))*
- `0.5.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.1/Dockerfile))*
- `0.5.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.0/Dockerfile))*
- `0.4.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.2/Dockerfile))*
- `0.4.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.1/Dockerfile))*
- `0.4.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.0/Dockerfile))*
- `0.3.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.2/Dockerfile))*
- `0.3.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.1/Dockerfile))*
- `0.3.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.0/Dockerfile))*
- `0.2.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.2.1/Dockerfile))*
- `0.2.0-2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.2.0-2/Dockerfile))*

# What is Kong?

[Kong](https://github.com/Mashape/kong) was built to secure, manage and extend
Microservices & APIs. If you're building for web, mobile or IoT (Internet of
Things) you will likely end up needing to implement common functionality on top
of your actual software. Kong can help by acting as a gateway for any HTTP
resource while providing logging, authentication and other functionality
through plugins.

Powered by NGINX with a focus on high performance and reliability, Kong runs in
production at Mashape where it has handled billions of API requests for over
ten thousand APIs.

Kong's documentation can be found at [getkong.org/docs][kong-docs-url]. Feel
free to browse our [FAQ](https://getkong.org/about/faq/)

# How to use this image

First, Kong requires its datastore to be running before it starts. It supports
both Cassandra (`2.1`/`2.2`) and PostgreSQL (`9.4`). Our
[FAQ](https://getkong.org/about/faq/) can give you some insight as to which of
those two will suit your needs.

## 1. Link Kong to a Cassandra or PostgreSQL container

Start a Cassandra container by doing so:

```shell
$ docker run -d --name kong-datastore \
    -p 9042:9042 \
    cassandra:2.2.5
```

If you wish to use PostgreSQL, start a container with:

```shell
$ docker run -d --name kong-datastore \
    -p 5423:5432 \
    postgres:9.4
```

Once your datastore container is running, we can start a Kong container and
link it to the datastore:

```shell
$ docker run -d --name kong \
    --link kong-datastore:kong-datastore \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    --security-opt seccomp:unconfined \
    mashape/kong
```

If everything went well, and if you created your container with the default
ports, Kong should be listening on your host's `8000`
([proxy][kong-docs-proxy-port]) and `8001` ([admin
api][kong-docs-admin-api-port]) ports.

You can now read the docs at [getkong.org/docs][kong-docs-url] to learn more
about Kong.

## 2. Use Kong with a custom configuration

This container stores the [Kong configuration
file](http://getkong.org/docs/latest/configuration/) in a [Data
Volume][docker-data-volume]. You can store this file on your host (name it
`kong.yml` and place it in a directory) and mount it as a volume by doing so:

```shell
$ docker run -d \
    -v /kong/configuration/dir/:/etc/kong/ \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    --security-opt seccomp:unconfined \
    --name kong \
    mashape/kong
```

When attached this way you can edit your configuration file from your host
machine and restart your container. You can also make the container point to a
different datastore instance, one that does not necessarily run in a Docker
container

## Reload Kong in a running container

If you change your custom configuration, you can reload Kong (without downtime)
by issuing:

```shell
$ docker exec -it kong kong reload
```

This will run the [`kong reload`][kong-docs-reload] command in your container.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us
through a [GitHub issue][github-new-issue].

## Contributing

You are invited to contribute new features, fixes, or updates, large or small;
we are always thrilled to receive pull requests, and do our best to process
them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub
issue][github-new-issue], especially for more ambitious contributions. This
gives other contributors a chance to point you in the right direction, give you
feedback on your design, and help you find out if someone else is working on
the same thing.

[kong-site-url]: http://getkong.org
[kong-docs-url]: http://getkong.org/docs
[kong-docs-proxy-port]: http://getkong.org/docs/latest/configuration/#proxy_port
[kong-docs-admin-api-port]: http://getkong.org/docs/latest/configuration/#admin_api_port
[kong-docs-reload]: http://getkong.org/docs/latest/cli/#reload

[github-new-issue]: https://github.com/Mashape/docker-kong/issues/new
[docker-data-volume]: https://docs.docker.com/userguide/dockervolumes/
