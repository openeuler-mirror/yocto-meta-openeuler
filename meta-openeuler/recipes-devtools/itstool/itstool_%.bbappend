OPENEULER_SRC_URI_REMOVE = "https http"

SRC_URI:prepend = " \
            file://${BPN}-${PV}.tar.bz2 \
           "