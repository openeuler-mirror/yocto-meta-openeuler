# avoid download online
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PV = "1.0"

SRC_URI:remove = "git://git.yoctoproject.org/prelink-cross.git;branch=cross_prelink_staging \
"

SRC_URI:prepend = "file://${BPN}-cross-${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-cross-${PV}"
