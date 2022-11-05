# avoid download online
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PV = "1.0"

SRC_URI_remove = "git://git.yoctoproject.org/prelink-cross.git;branch=cross_prelink_staging \
"

SRC_URI_prepend = "file://${BPN}-cross-${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-cross-${PV}"
