OPENEULER_LOCAL_NAME = "nss-mdns"

SRC_URI:prepend = " \
    file://nss-mdns-${PV}.tar.gz \
"

S = "${WORKDIR}/nss-mdns-${PV}"
