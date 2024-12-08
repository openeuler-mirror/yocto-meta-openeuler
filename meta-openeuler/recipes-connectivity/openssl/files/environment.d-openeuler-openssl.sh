# merge relative env from buildtools-tarball.bb create_sdk_files task
export GIT_SSL_CAINFO="$OECORE_NATIVE_SYSROOT/etc/ssl/certs/ca-bundle.crt"
export REQUESTS_CA_BUNDLE="$OECORE_NATIVE_SYSROOT/etc/ssl/certs/ca-bundle.crt"
export CURL_CA_BUNDLE="$OECORE_NATIVE_SYSROOT/etc/ssl/certs/ca-bundle.crt"

# override environment.d-openssl.sh in poky openssl
export OPENSSL_CONF="$OECORE_NATIVE_SYSROOT/usr/lib/ssl-3/openssl.cnf"
export SSL_CERT_DIR="$OECORE_NATIVE_SYSROOT/usr/lib/ssl-3/certs"
export SSL_CERT_FILE="$OECORE_NATIVE_SYSROOT/usr/lib/ssl-3/certs/ca-bundle.crt"
export OPENSSL_MODULES="$OECORE_NATIVE_SYSROOT/usr/lib/ossl-modules/"
export OPENSSL_ENGINES="$OECORE_NATIVE_SYSROOT/usr/lib/engines-3"
