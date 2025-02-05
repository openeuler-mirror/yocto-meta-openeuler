OPENEULER_LOCAL_NAME = "libxcrypt"

PV = "4.4.36"

SRC_URI:prepend = "file://v${PV}.tar.gz \
           "

S = "${WORKDIR}/libxcrypt-${PV}"
