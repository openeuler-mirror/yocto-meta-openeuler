SRC_URI:remove = "http://downloads.yoctoproject.org/releases/${BPN}/${BPN}-${PV}.tar.gz \
"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.5.0"

# from oee_archive
SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}-${PV}.tar.gz \
"
