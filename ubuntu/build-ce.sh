VERSION=${VERSION:-2.0.1} && \
curl -L "https://bintray.com/kong/kong-deb/download_file?file_path=kong-$VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb
