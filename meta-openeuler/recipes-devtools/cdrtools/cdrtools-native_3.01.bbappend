OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR = "cdrtools"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/cdrtools/cdrtools-${PV}.tar.bz2 \
"

