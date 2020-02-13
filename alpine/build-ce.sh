VERSION=${VERSION:-2.0.0} && \
curl -L "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$VERSION.amd64.apk.tar.gz" -o /tmp/kong.tar.gz
echo "5af1178111958b2e325c5b18690f4e7ddf064d28139ff38188b1e2e432ea99ff  /tmp/kong.tar.gz" | sha256sum -c -