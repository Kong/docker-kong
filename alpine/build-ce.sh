VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$VERSION.amd64.apk.tar.gz" -o /tmp/kong.tar.gz
echo "befe736bfde51e27ae51a0d6a827df44a1669099dea459d430aef0d570cc4db7  /tmp/kong.tar.gz" | sha256sum -c -