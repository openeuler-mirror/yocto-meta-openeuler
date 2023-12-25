# openeuler version
PV = "3.1"

OPENEULER_SRC_URI_REMOVE = "git https http"

OPENEULER_LOCAL_NAME = "oee_archive"

# upstream source
SRC_URI:prepend = " \
            file://${OPENEULER_LOCAL_NAME}/${BPN}/libnss-nis-${PV}.tar.gz  \
           "
