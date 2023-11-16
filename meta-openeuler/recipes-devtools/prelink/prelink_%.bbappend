OPENEULER_LOCAL_NAME = "oee_archive"

PV = "1.0"

SRC_URI:remove = "git://git.yoctoproject.org/prelink-cross.git;branch=cross_prelink_staging \
"

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}-cross-${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-cross-${PV}"
