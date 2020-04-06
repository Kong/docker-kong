VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$VERSION.amd64.apk.tar.gz" -o /tmp/kong.tar.gz
echo "db6a8ac847c347fb4d49c4763181c529bb9584187cdccdcc657ce00d605c99ac  /tmp/kong.tar.gz" | sha256sum -c -