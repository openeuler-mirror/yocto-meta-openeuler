require selinux_common.inc
require ${BPN}.inc

LIC_FILES_CHKSUM = "file://LICENSE;md5=84b4d2c6ef954a2d4081e775a270d0d0"

SRC_URI = "file://libselinux/libselinux-${PV}.tar.gz \
           file://libselinux/do-malloc-trim-after-load-policy.patch \
"
