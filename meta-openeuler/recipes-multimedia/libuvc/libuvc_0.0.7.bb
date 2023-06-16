# ref: yocto-meta-openembedded/meta-multimedia/recipes-multimedia/libuvc/libuvc.bb
# but libuvc recipes of yocto-meta-openembedded not work properly

SUMMARY = "library for USB video devices built atop libusb"
HOMEPAGE = "https://github.com/libuvc/libuvc.git"
SECTION = "libs"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=2f1963e0bb88c93463af750daf9ba0c2"
DEPENDS = "libusb jpeg"

inherit openeuler_source

S = "${WORKDIR}/git"

inherit cmake

