VERSION=${VERSION:-2.0.2} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$VERSION.el7.amd64.rpm" -o /tmp/kong.rpm
echo "e10fed33015f0154eda881cd0e2cbe1626b24db9689e8d20b2ffc1344afd9f88  /tmp/kong.rpm" | sha256sum -c -