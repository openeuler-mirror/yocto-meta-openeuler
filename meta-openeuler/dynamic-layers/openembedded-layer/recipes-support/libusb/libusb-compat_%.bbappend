OPENEULER_REPO_NAME = "libusb"
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "0.1.8"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           file://0000-Link-with-znodelete-to-disallow-unloading.patch \
"

SRC_URI[sha256sum] = "404ef4b6b324be79ac1bfb3d839eac860fbc929e6acb1ef88793a6ea328bc55a"

S = "${WORKDIR}/${BP}"

# backport from meta-oe/recipes-support/libusb/libusb-compat_0.1.8.bb
# libusb-compat dlopen() libusb1 so we need to explicitly RDEPENDS on it
RDEPENDS:${PN} += "libusb1"
