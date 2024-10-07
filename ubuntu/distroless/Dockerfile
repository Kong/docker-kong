#####################
## Build stage
#####################
FROM ubuntu:jammy AS build
LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=3.7.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="58e380961fc90c6b4dfd62f4ee596ab053afe5ae72a93445c4356f496f2dc9ec"
ARG KONG_ARM64_SHA="602a68cf3a09bbea26106d4bd4041c242d7913e40582d18cac0f6958aad78f72"

# hadolint ignore=DL3015
RUN set -ex; \
    arch=$(dpkg --print-architecture); \
    case "${arch}" in \
      amd64) KONG_SHA256=$KONG_AMD64_SHA ;; \
      arm64) KONG_SHA256=$KONG_ARM64_SHA ;; \
    esac; \
    apt-get update \
    && if [ "$ASSET" = "ce" ] ; then \
      apt-get install -y --no-install-recommends curl ca-certificates \
      && UBUNTU_CODENAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2) \
      && KONG_REPO=$(echo ${KONG_VERSION%.*} | sed 's/\.//') \
      && curl -fL https://packages.konghq.com/public/gateway-$KONG_REPO/deb/ubuntu/pool/$UBUNTU_CODENAME/main/k/ko/kong_$KONG_VERSION/kong_${KONG_VERSION}_$arch.deb -o /tmp/kong.deb \
      && apt-get purge -y curl \
      && echo "$KONG_SHA256  /tmp/kong.deb" | sha256sum -c - \
      || exit 1; \
    else \
      # this needs to stay inside this "else" block so that it does not become part of the "official images" builds (https://github.com/docker-library/official-images/pull/11532#issuecomment-996219700)
      apt-get upgrade -y ; \
    fi; \
    apt-get install -y --no-install-recommends unzip git \
    # Please update the ubuntu install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && apt install --yes --no-install-recommends /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/kong.deb \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -sf /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && if [ "$ASSET" = "ce" ] ; then \
      kong version ; \
    fi

#####################
## Distroless stage
#####################
FROM  distroless-kong-base:0.0.1
USER root

WORKDIR /app

# Add the kong user and group
COPY <<EOF /etc/group
root:x:0:
kong:x:1000:
nobody:x:1:
nogroup:x:2:
EOF

COPY <<EOF /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
kong:x:1000:1000:kong:/home/kong:/sbin/nologin
nobody:x:1:1:nobody:/home/nobody:/sbin/nologin
nogroup:x:2:2:nogroup:/home/nogroup:/sbin/nologin
EOF


# Copy necessary binaries and libraries from build stage
COPY --from=build /usr/local/openresty/luajit/lib/libluajit-5.1.so.2 /usr/lib/x86_64-linux-gnu/
COPY --from=build "/usr/lib/x86_64-linux-gnu/libstdc++.so.6" "/usr/lib/"
COPY --from=build /lib32 /lib32/
COPY --from=build /usr/local/bin/luajit /usr/local/bin/luajit
COPY --from=build /usr/local/openresty/luajit/include/ /usr/local/openresty/luajit/include/
COPY --from=build /usr/local/bin/luarocks /usr/local/bin/luarocks
COPY --from=build /usr/local/openresty/luajit/lib /usr/local/openresty/luajit/lib
COPY --from=build /usr/local/openresty/luajit/share /usr/local/openresty/luajit/share
COPY --from=build /usr/local/bin/lua /usr/local/bin/lua
COPY --from=build /usr/local/openresty/lualib/ /usr/local/openresty/lualib/
COPY --from=build /usr/local/share/lua /usr/local/share/lua
COPY --from=build /usr/local/share/lua/5.1 /usr/local/share/lua/5.1
COPY --from=build /usr/lib/x86_64-linux-gnu/perl-base/ /usr/lib/
COPY --from=build /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.6
COPY --from=build /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2


# Copy Kong installation
COPY --from=build /usr/local/kong /usr/local/kong
COPY --from=build /usr/local/bin/kong /usr/local/bin/kong
COPY --from=build /usr/local/bin/resty /usr/local/bin/resty
COPY --from=build /usr/local/openresty/bin/resty /usr/local/openresty/bin/resty
COPY --from=build /usr/local/bin/luajit /usr/local/bin/luajit 
COPY --from=build /usr/local/openresty/luajit/bin/luajit /usr/local/openresty/luajit/bin/luajit 
COPY --from=build /usr/local/openresty/nginx/ /usr/local/openresty/nginx/ 
COPY --from=build /usr/local/bin/nginx /usr/local/bin/nginx
COPY --from=build /usr/bin/env /usr/bin/env
COPY --from=build /usr/bin/perl /usr/bin/perl
COPY --from=build /usr/share/perl5 /usr/share/perl5
COPY --from=build /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=build /usr/local/share/lua/5.1/ffi-zlib.lua /usr/local/share/lua/5.1/
COPY --from=build /usr/local/lib/ /usr/local/lib/


# Copy additional libraries and plugins
# COPY plugins/ /opt/kong/plugins/
# COPY libraries/ /opt/kong/lib/
COPY --from=build /usr/lib/x86_64-linux-gnu/libhogweed* /usr/lib/

# Apply core patches
COPY --from=build /usr/local/share/lua/5.1/ /usr/local/share/lua/5.1/
# Copy the entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh


ENTRYPOINT ["sh","/app/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

CMD ["kong", "docker-start"]


