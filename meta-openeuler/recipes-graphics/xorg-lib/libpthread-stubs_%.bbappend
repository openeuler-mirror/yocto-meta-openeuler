# openeuler PV
PV = "0.4"

# remove poky src_uri
OPENEULER_SRC_URI_REMOVE = "git https http"

OPENEULER_LOCAL_NAME = "oee_archive"

# upstream source
SRC_URI:prepend = " \
            file://${OPENEULER_LOCAL_NAME}/${BPN}/libpthread-stubs-${PV}.tar.bz2  \
           "
