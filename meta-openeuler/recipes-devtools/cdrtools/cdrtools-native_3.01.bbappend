OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/cdrtools/cdrtools-${PV}.tar.bz2 \
"
