# Kong in Docker

This is the official Docker image for [Kong][kong-site-url].

# Supported tags and respective `Dockerfile` links

- `0.2.0-2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.2.0-2/Dockerfile))*
- `0.2.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.2.1/Dockerfile))*
- `0.3.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.0/Dockerfile))*
- `0.3.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.1/Dockerfile))*
- `0.3.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.3.2/Dockerfile))*
- `0.4.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.0/Dockerfile))*
- `0.4.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.1/Dockerfile))*
- `0.4.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.4.2/Dockerfile))*
- `0.5.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.0/Dockerfile))*
- `0.5.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.1/Dockerfile))*
- `0.5.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.2/Dockerfile))*
- `0.5.3` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.3/Dockerfile))*
- `0.5.4` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.5.4/Dockerfile))*
- `0.6.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.6.0/Dockerfile))*
- `0.6.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.6.1/Dockerfile))*
- `0.7.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.7.0/Dockerfile))*
- `0.8.0` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.8.0/Dockerfile))*
- `0.8.1` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.8.1/Dockerfile))*
- `0.8.2` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.8.2/Dockerfile))*
- `latest` - *([Dockerfile](https://github.com/Mashape/docker-kong/blob/0.8.2/Dockerfile))*

# What is Kong?

Kong was built to secure, manage and extend Microservices & APIs. If you're building for web, mobile or IoT (Internet of Things) you will likely end up needing to implement common functionality on top of your actual software. Kong can help by acting as a gateway for any HTTP resource while providing logging, authentication and other functionality through plugins.

Powered by NGINX and Cassandra with a focus on high performance and reliability, Kong runs in production at Mashape where it has handled billions of API requests for over ten thousand APIs.

Kong's documentation can be found at [getkong.org/docs][kong-docs-url].

# How to use this image

First, Kong requires a running Cassandra or PostgreSQL cluster before it starts. You can either use the official Cassandra/PostgreSQL containers, or use your own.

## 1. Link Kong to either a Cassandra or PostgreSQL container

It's up to you to decide which datastore between Cassandra or PostgreSQL you want to use, since Kong supports both.

### Cassandra

Start a Cassandra container by executing:

```shell
$ docker run -d --name kong-database \
                -p 9042:9042 \
                cassandra:2.2
```

### Postgres

Start a PostgreSQL container by executing:

```shell
docker run -d --name kong-database \
                -p 5432:5432 \
                -e "POSTGRES_USER=kong" \
                -e "POSTGRES_DB=kong" \
                postgres:9.4
```

### Start Kong

Once the database is running, we can start a Kong container and link it to the database container, and configuring the `DATABASE` environment variable with either `cassandra` or `postgres` depending on which database you decided to use:

```shell
$ docker run -d --name kong \
    -e "DATABASE=cassandra" \
    --link kong-database:kong-database \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    --security-opt seccomp:unconfined \
    mashape/kong
```

**Note:** If Docker complains that `--security-opt` is an invalid option, just remove it and re-execute the command (it was introduced in Docker 1.3).

If everything went well, and if you created your container with the default ports, Kong should be listening on your host's `8000` ([proxy][kong-docs-proxy-port]), `8443` ([proxy SSL][kong-docs-proxy-ssl-port]) and `8001` ([admin api][kong-docs-admin-api-port]) ports. Port `7946` ([cluster][kong-docs-cluster-port]) is being used only by other Kong nodes.

You can now read the docs at [getkong.org/docs][kong-docs-url] to learn more about Kong.

## 2. Use Kong with a custom configuration (and a custom Cassandra/PostgreSQL cluster)

This container stores the [Kong configuration file](http://getkong.org/docs/latest/configuration/) in a [Data Volume][docker-data-volume]. You can store this file on your host (name it `kong.yml` and place it in a directory) and mount it as a volume by doing so:

```shell
$ docker run -d \
    -v /path/to/your/kong/configuration/directory/:/etc/kong/ \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    --security-opt seccomp:unconfined \
    --name kong \
    mashape/kong
```

When attached this way you can edit your configuration file from your host machine and restart your container. You can also make the container point to a different Cassandra/PostgreSQL instance, so no need to link it to a Cassandra/PostgreSQL container.

## Reload Kong in a running container

If you change your custom configuration, you can reload Kong (without downtime) by issuing:

```shell
$ docker exec -it kong kong reload
```

This will run the [`kong reload`][kong-docs-reload] command in your container.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue][github-new-issue].

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue][github-new-issue], especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

[kong-site-url]: http://getkong.org
[kong-docs-url]: http://getkong.org/docs
[kong-docs-proxy-port]: http://getkong.org/docs/latest/configuration/#proxy_port
[kong-docs-proxy-ssl-port]: http://getkong.org/docs/latest/configuration/#proxy_listen_ssl
[kong-docs-admin-api-port]: http://getkong.org/docs/latest/configuration/#admin_api_port
[kong-docs-cluster-port]: http://getkong.org/docs/latest/configuration/#cluster_listen
[kong-docs-reload]: http://getkong.org/docs/latest/cli/#reload

[github-new-issue]: https://github.com/Mashape/docker-kong/issues/new
[docker-data-volume]: https://docs.docker.com/userguide/dockervolumes/
