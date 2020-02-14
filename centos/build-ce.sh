VERSION=${VERSION:-2.0.1} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$VERSION.el7.amd64.rpm" -o /tmp/kong.rpm
echo "8b1c9b18fd6f2f149bd6cfa506d917d7920b547d480dd514248769e8fb47c6c5  /tmp/kong.rpm" | sha256sum -c -