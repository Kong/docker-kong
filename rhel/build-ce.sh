VERSION=${VERSION:-2.0.0} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$VERSION.rhel7.amd64.rpm" -o /tmp/kong.rpm
echo "0f1abc28d58e1092654ca9b58fbc725f560ca42ccab798cd55963ec5c5e0a317  /tmp/kong.rpm" | sha256sum -c -