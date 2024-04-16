OPENEULER_LOCAL_NAME = "nss-mdns"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/nss-mdns-${PV}.tar.gz \
"

S = "${WORKDIR}/nss-mdns-${PV}"

