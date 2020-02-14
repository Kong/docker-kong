VERSION="1.3.0.1" && \
curl -L -u$BINTRAY_USER:$BINTRAY_KEY "https://kong.bintray.com/kong-enterprise-edition-rpm/rhel/7/kong-enterprise-edition-$VERSION.rhel7.noarch.rpm" -o /tmp/kong.rpm
echo "ad6216aaf476a2806b208ca8a175a6c96013a6149042a64de57f3d702de266ce  /tmp/kong.rpm" | sha256sum -c -