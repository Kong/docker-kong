VERSION=${VERSION:-2.0.1} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$VERSION.rhel7.amd64.rpm" -o /tmp/kong.rpm
echo "068b95244dbf368bfb5e2af428047a3dcdc92c6239face0ad7e2b9ac5a5c7be2  /tmp/kong.rpm" | sha256sum -c -