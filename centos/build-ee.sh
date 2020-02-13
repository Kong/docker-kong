VERSION="1.3.0.1" && \
curl -L -u$BINTRAY_USER:$BINTRAY_KEY "https://kong.bintray.com/kong-enterprise-edition-rpm/centos/7/kong-enterprise-edition-$VERSION.el7.noarch.rpm" -o /tmp/kong.rpm
echo "56938ea59bb608d2369d714bce1462b0b4f7e30ad9bdfa14135fa95356f8ffb3  /tmp/kong.rpm" | sha256sum -c -