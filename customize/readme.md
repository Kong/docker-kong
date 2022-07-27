# Customize Kong by injecting plugins and templates

This dockerfile takes an existing Kong image and adds custom plugins
and/or a custom template file to it.

```
docker build \
   --build-arg KONG_BASE="kong:0.14.1-alpine" \
   --build-arg PLUGINS="kong-http-to-https,kong-upstream-jwt" \
   --build-arg TEMPLATE="/mykong/nginx.conf" \
   --build-arg "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
   --tag "your_new_image" .
```

The above command will take the `kong:0.14.1-alpine` image and add the plugins
(as known on [luarocks.org](https://luarocks.org)) `kong-http-to-https` and
`kong-upstream-jwt` to it. Also the custom template ([for rendering the
underlying nginx configuration file](https://docs.konghq.com/latest/configuration/#custom-nginx-templates--embedding-kong)
), located at `/mykong/nginx.conf` will be injected.
The resulting new image will be tagged as `your_new_image`.

When starting a container from the newly created image, the added plugins and
template will automatically be applied. So there is no need to specify the
environment variable `KONG_PLUGINS` nor the `--nginx-conf` command line
switch to enable them.

# Checking the available plugins

To check the plugins available in an image, use the example
[`list_plugins.sh`](list_plugins.sh) script.

# Curated list of plugins

This tool is based on the LuaRocks packagemanager to include all plugin
dependencies. The `ROCKS_DIR` variable allows you to only use a curated list of
rocks to be used (instead of the public ones).

It will generate a local LuaRocks server, and not allow any public ones to be
used. For an example of how to use it see the [`example.sh`](example.sh) script.

## Arguments:

 - `KONG_BASE` the base image to use, defaults to `kong:latest`.
 - `PLUGINS` a comma-separated list of the plugin names (NOT rock files!) that you wish to add to the image. All
   dependencies will also be installed.
 - `ROCKS_DIR` a local directory where the allowed plugins/rocks are located. If
   specified, only rocks from this location will be allowed to be installed. If
   not specified, then the public `luarocks.org` server is used.
 - `TEMPLATE` the custom configuration template to use
 - `KONG_LICENSE_DATA` this is required when the base image is an Enterprise
   version of Kong.

Note that the `PLUGINS` entries are simply LuaRocks commands used as:
`luarocks install <entry>`. So anything that LuaRocks accepts can be added
there, including commandline options. For example:

```
--build-arg PLUGINS="luassert --deps-mode=none"
```

Will add the `luassert` module, without resolving dependencies (this is useless,
but demonstrates how it works).


## Limitations

- Only works for pure-Lua modules for now.
