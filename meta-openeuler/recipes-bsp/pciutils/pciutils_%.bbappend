PV = "3.8.0"

SRC_URI[sha256sum] = "f79fadc7fc88750877e4474c22e4b2d627e3d97d9445d1a04a88ca1d701f070f"

SRC_URI = " \
    file://pciutils-${PV}.tar.gz \
    file://0000-pciutils-2.2.1-idpath.patch \
    file://0001-pciutils-dir-d.patch \
"

# use new configure.patch to fix build error of pciutils
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"
SRC_URI += " \
    file://configure.patch \
"

# file of ids package is /usr/share/hwdata/pci.ids.gz, but datadir is /usr/share/
# update it from FILES_${PN}-ids = "${datadir}/pci.ids*" in poky bb.
FILES_${PN}-ids = "${datadir}/*/pci.ids*"

# In 3.8.0, lspci location is ${D}${bindir}/lspci, not ${D}/sbin/lspci
do_install_remove() {
    ln -s ../sbin/lspci ${D}${bindir}/lspci
}
