VERSION="2.0.0" && \
curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$VERSION.el7.amd64.rpm" -o /tmp/kong.rpm
echo "5a7454cc205d3c6b0f24193e3b4f5192f2afb0cdfc217ec253b63afd316169d9  /tmp/kong.rpm" | sha256sum -c -