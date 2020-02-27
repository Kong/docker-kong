VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-deb/download_file?file_path=kong-$VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb
echo "b0d78ad8fbfaf9bb5eb6d5b582844d50ba94b321801985ee4b7b9cc710204bff  /tmp/kong.deb" | sha256sum -c -