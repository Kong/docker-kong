VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$VERSION.rhel7.amd64.rpm" -o /tmp/kong.rpm
echo "5d9dbf8e51a71a2dd4e8d3c94d511726de3b4dd6ad85e4b7e5f4fe157298b8c3  /tmp/kong.rpm" | sha256sum -c -