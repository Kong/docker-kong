VERSION=${VERSION:-2.0.1} && \
curl -L "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$VERSION.amd64.apk.tar.gz" -o /tmp/kong.tar.gz
echo "170e3f230640cef9e307fd8411287b05a1ba9162b3fc1b53417f199869dcf065  /tmp/kong.tar.gz" | sha256sum -c -