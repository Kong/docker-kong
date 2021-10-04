# Kong in Docker Compose

This is the official Docker Compose template for [Kong][kong-site-url].

# What is Kong?

You can find the official Docker distribution for Kong at [https://hub.docker.com/_/kong](https://hub.docker.com/_/kong).

# How to use this template

This Docker Compose template supports the following deployments:
- Kong container with a Postgres database plus a nginx load-balancer, provisioned with `make kong-postgres`
- A db-less version of Kong, provisioned with `make kong-dbless`

Kong will be available through the `nginx-lb` instance on port `8000`, and `8001`. You can customize the template with your own environment variables or datastore configuration.

Kong's documentation can be found at [https://docs.konghq.com/][kong-docs-url].

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue][github-new-issue].

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue][github-new-issue], especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

[kong-site-url]: https://konghq.com/
[kong-docs-url]: https://docs.konghq.com/
[github-new-issue]: https://github.com/Kong/docker-kong/issues/new
