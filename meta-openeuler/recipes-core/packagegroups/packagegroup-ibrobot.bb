SUMMARY = "packages for ibrobot feature of openEuler Embedded"
PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN}:append = " \
    opencv \
    opencv-dev \
"

INSTALL_PKG_LISTS:apppend = " \
    opencv \
"
