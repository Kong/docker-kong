VERSION="2.0.0" && \
curl -L "https://bintray.com/kong/kong-deb/download_file?file_path=kong-$VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb
echo "8ad1d8c53ecbf3f5b8e6d7e629faaac13f862919865c3cd106a38ea5aed384db  /tmp/kong.deb" | sha256sum -c -