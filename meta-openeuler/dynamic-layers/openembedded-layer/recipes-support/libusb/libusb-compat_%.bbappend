OPENEULER_LOCAL_NAME = "libusb"
PV = "0.1.8"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
SRC_URI:prepend = "file://${BP}.tar.bz2 \
           file://0000-Link-with-znodelete-to-disallow-unloading.patch \
           file://0001-usb.h-Include-sys-types.h-1.patch \
"

SRC_URI:remove = "file://0001-usb.h-Include-sys-types.h.patch"

SRC_URI[sha256sum] = "404ef4b6b324be79ac1bfb3d839eac860fbc929e6acb1ef88793a6ea328bc55a"

S = "${WORKDIR}/${BP}"

# backport from meta-oe/recipes-support/libusb/libusb-compat_0.1.8.bb
# libusb-compat dlopen() libusb1 so we need to explicitly RDEPENDS on it
RDEPENDS:${PN} += "libusb1"
