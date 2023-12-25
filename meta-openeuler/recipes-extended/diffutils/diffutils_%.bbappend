OPENEULER_SRC_URI_REMOVE = "https"

PV = "3.10"

# openeuler source
SRC_URI:prepend = "file://diffutils-${PV}.tar.xz \
           "

# remove poky-patch
SRC_URI:remove = "file://0001-Skip-strip-trailing-cr-test-case.patch"

# openeuler SRC_URI[sha256sum]
SRC_URI[sha256sum] = "90e5e93cc724e4ebe12ede80df1634063c7a855692685919bfe60b556c9bd09e"

S = "${WORKDIR}/diffutils-${PV}"
