VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$VERSION.rhel7.amd64.rpm" -o /tmp/kong.rpm
echo "886ce4e5b8cc3ecd38e82300114f151f4af440386397696602c041f65a7f2b9d  /tmp/kong.rpm" | sha256sum -c -