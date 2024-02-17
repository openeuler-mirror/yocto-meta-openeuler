# the main bb file: yocto-poky/meta/recipes-bsp/pciutils/pciutils_3.7.0.bb

PV = "3.9.0"

# update configure.patch of poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI:prepend = " \
    file://pciutils-${PV}.tar.gz \
    file://0000-pciutils-2.2.1-idpath.patch \
    file://0001-pciutils-dir-d.patch \
"

SRC_URI[sha256sum] = "01f5b9ee8eff577e9953a43bafb3ead76e0654a7288dc26d79627074956fb1e0"

# use newer do_install
do_install () {
	oe_runmake DESTDIR=${D} install install-lib
	install -d ${D}${bindir}
	oe_multilib_header pci/config.h
}

# avoid lspci conflict with busybox
inherit update-alternatives

ALTERNATIVE:${PN} = "lspci"
ALTERNATIVE_PRIORITY = "100"

# file of ids package is /usr/share/hwdata/pci.ids.gz, but datadir is /usr/share/
# update it from FILES:${PN}-ids = "${datadir}/pci.ids*" in poky bb.
FILES:${PN}-ids = "${datadir}/*/pci.ids*"
