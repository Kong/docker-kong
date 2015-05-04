# docker-kong

This is the official Docker image for [Kong][kong-repo-url]. You can read Kong's documentation at [getkong.org/docs][kong-docs-url].

This image is hosted on Dockerhub at [mashape/kong](https://registry.hub.docker.com/u/mashape/kong/).

# Usage

First, Kong requires a running Cassandra before it starts. You can either use the [mashape/cassandra](https://github.com/Mashape/docker-cassandra) image or provision a test instance on [kongdb.org](http://kongdb.org).

#### Link to the mashape/cassandra image (default).

```shell
$ docker run -d -p 9042:9042 --name cassandra mashape/cassandra
```

Once Cassandra is running, we can start a Kong container and link it with the Cassandra container:

```shell
$ docker run -d -p 8000:8000 -p 8001:8001 --name kong --link cassandra:cassandra mashape/kong
```

This will make Kong listen on your machine on ports `8000` ([proxy port](http://getkong.org/docs/latest/configuration/#proxy_port)), and  `8001` ([Admin API port](http://getkong.org/docs/latest/configuration/#admin_api_port)). Make sure those ports are free. If you wish to change these ports, keep in mind that the `-p` arguments expects: `host-port:container-port`. Feel free to change the host port.

#### Volumes and custom configuration

This container stores the [Kong configuration file](http://getkong.org/docs/latest/configuration/) in a Docker volume. You can store this file on your host's file system (name it `kong.yml` and place it in a directory) and give access to it to your container by using the `-v` argument:

```shell
$ docker run -d \
    -v /path/to/your/kong/configuration/directory/:/etc/kong/ \
    -p 8000:8000 -p 8001:8001 \
    --name kong \
    --link cassandra:cassandra \
    mashape/kong
```

When attached this way you can edit your configuration file from your host machine and restart your container. You can also make the container point to a different instance of Cassandra.

##### OS X with boot2docker

To run docker on OS X, follow the instructions at [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/)

Once the environment is ready, open the ports Kong will be using on your boot2docker VM (by default `8000` and `8001`):

```shell
$ boot2docker down # be sure boot2docker is not running
$ VBoxManage modifyvm "boot2docker-vm" --natpf1 "kong-proxy-port,tcp,,8000,,8000"
$ VBoxManage modifyvm "boot2docker-vm" --natpf1 "kong-admin-api-port,tcp,,8001,,8001"
$ boot2docker up
```

# Enjoy

If everything went well, and if you created your container with the default ports, Kong should be listening on `127.0.0.1:8000` and `127.0.0.1:8001`. You can now read the docs at [getkong.org/docs][kong-docs-url] to learn how to use it.

[kong-repo-url]: https://github.com/Mashape/kong
[kong-docs-url]: http://getkong.org/docs
