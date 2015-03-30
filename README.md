# docker-kong
This is the official Docker distribution for [Kong][kong-repo-url]. You can find the official documentation at [getkong.org/docs][kong-docs-url]

# Usage

If you are an OS X user please [read this](#os-x-with-boot2docker) first.

Using Kong with Docker is easy. First, remember that Kong requires a running Cassandra before it starts, so let's run the Cassandra Docker image first:

```bash
docker run -p 9042:9042 -d --name cassandra mashape/docker-cassandra
```

Once Cassandra is running, we can start the Kong container and link it with the Cassandra container:

```bash
docker run -p 8000:8000 -p 8001:8001 -d --name kong --link cassandra:cassandra mashape/docker-kong:0.1.1beta-1
```

Since Kong listens by default on ports `8000` and `8001`, we also make the same ports available on your system. Make sure that these ports are available before starting Docker and they are not used by another process on your computer.

### OS X with boot2docker

To run docker on OS X, follow the instructions at [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/)

Once the environment is ready, remember to run the following command before starting Docker to initialize `boot2docker` and setup port forwarding:

```
boot2docker down; \
PORTS=( 8000 8001 9042 ); \
for port in "${PORTS[@]}"; do VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port${port},tcp,,${port},,${port}"; done; \
boot2docker up;
```

# Enjoy

If everything went well, Kong should be listening at `127.0.0.1:8000` and `127.0.0.1:8001`. You can now read the docs at [getkong.org/docs][kong-docs-url] to learn how to use it.

[kong-repo-url]: https://github.com/Mashape/kong
[kong-docs-url]: http://getkong.org/docs
