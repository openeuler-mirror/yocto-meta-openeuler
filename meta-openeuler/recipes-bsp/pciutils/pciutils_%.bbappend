PV = "3.8.0"

# update configure.patch of poky
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

OPENEULER_SRC_URI_REMOVE = "https http git"

SRC_URI_prepend = " \
    file://pciutils-${PV}.tar.gz \
    file://0000-pciutils-2.2.1-idpath.patch \
    file://0001-pciutils-dir-d.patch \
"

SRC_URI[sha256sum] = "f79fadc7fc88750877e4474c22e4b2d627e3d97d9445d1a04a88ca1d701f070f"

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
# update it from FILES_${PN}-ids = "${datadir}/pci.ids*" in poky bb.
FILES_${PN}-ids = "${datadir}/*/pci.ids*"
