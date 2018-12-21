# Inject custom plugins in a docker image

This dockerfile takes an existing Kong container and adds a custom plugin to
it. This is based on the LuaRocks packagemanager to include all dependencies.

```
docker build \
   --build-arg KONG_BASE="kong-ee" \
   --build-arg PLUGINS="kong-http-to-https,kong-upstream-jwt" \
   --tag "your_new_image" .
```

The above command will take the local `kong-ee` image and add the plugins (as
known on [luarocks.org](https://luarocks.org)) `kong-http-to-https` and
`kong-upstream-jwt` to it. The resulting new image will be tagged as
`your_new_image`.

## Arguments:

 - `KONG_BASE` the base image to use, defaults to `kong:latest`.
 - `PLUGINS` a comma-separated list of LuaRocks rocks to add to the image. All
   dependencies will also be installed.

Note that the `PLUGINS` entries are simply LuaRocks commands used as:
`luarocks install <entry>`. So anything that LuaRocks accepts can be added
there, including commandline options. For example:

```
--build-arg PLUGINS="luassert --deps-mode=none"
```

Will add the `luassert` module, without resolving dependencies (this is useless,
but demonstrates how it works).

## Resulting image

The resulting image will have the additional plugins/rocks installed. The added
plugins will also be added to the Kong environment variables `KONG_PLUGINS` and
`KONG_CUSTOM_PLUGINS` to enable them.


## Limitations

- Only works for pure-Lua modules for now.
- Only works with the Alpine image (others should be easy to add, see
  `platforms` table in `packer.lua`)
