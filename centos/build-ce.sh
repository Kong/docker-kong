VERSION=${VERSION:-2.0.3} && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$VERSION.el7.amd64.rpm" -o /tmp/kong.rpm
echo "5a97052bfc782a1a5136b0fbd006776ccd5027a9340f7e09c3c8fb2eddf22efc  /tmp/kong.rpm" | sha256sum -c -