require openeuler-xorg-lib-common.inc

OPENEULER_REPO_NAME = "xorg-x11-xtrans-devel"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=bc875e1c864f4f62b29f7d8651f627fa"

XORG_EXT = "tar.gz"

PV = "1.5.0"

# openeuler patches
SRC_URI:prepend = "file://xtrans-1.0.3-avoid-gethostname.patch \
           "
