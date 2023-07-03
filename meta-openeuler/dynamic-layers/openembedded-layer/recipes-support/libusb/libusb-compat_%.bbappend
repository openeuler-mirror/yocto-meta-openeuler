OPENEULER_REPO_NAME = "libusb"
OPENEULER_SRC_URI_REMOVE = "https http git"

# modify 0001-usb.h-Include-sys-types.h.patch
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

PV = "0.1.5"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           file://0000-Link-with-znodelete-to-disallow-unloading.patch \
           file://0001-Revert-use-atexit-to-call-libusb_exit.patch \
"

SRC_URI[sha256sum] = "404ef4b6b324be79ac1bfb3d839eac860fbc929e6acb1ef88793a6ea328bc55a"

S = "${WORKDIR}/${BP}"
