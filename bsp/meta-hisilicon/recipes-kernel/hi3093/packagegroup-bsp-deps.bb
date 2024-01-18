SUMMARY = "bsp modules deps"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} += " \
    kernel-module-mtd \
    kernel-module-chipreg \
    kernel-module-map-funcs \
    kernel-module-can-dev \
"

