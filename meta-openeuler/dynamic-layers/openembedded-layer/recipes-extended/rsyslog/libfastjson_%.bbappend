# main bbfile: meta-oe/recipes-extended/rsyslog/libfastjson_0.99.9.bb?h=hardknott

PV = "1.2304.0"

SRC_URI = " \
    file://${BP}.tar.gz \
"

SRC_URI[md5sum] = "b4668f067145d4eb2a44433d5256f277"
SRC_URI[sha256sum] = "a330e1bdef3096b7ead53b4bad1a6158f19ba9c9ec7c36eda57de7729d84aaee"

S = "${WORKDIR}/${BP}"
