PV = "1.4.0"

OPENEULER_SRC_URI_REMOVE = "http"
OPENEULER_LOCAL_NAME = "oee_archive"

# upstream source
SRC_URI:prepend = " \
            file://${OPENEULER_LOCAL_NAME}/${BPN}/python-subunit-${PV}.tar.gz  \
           "

SRC_URI[sha256sum] = "042039928120fbf392e8c983d60f3d8ae1b88f90a9f8fd7188ddd9c26cad1e48"
