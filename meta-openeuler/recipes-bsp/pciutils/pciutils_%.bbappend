SRC_URI[sha256sum] = "2432e7a2e12000502d36cf769ab6e5a0cf4931e5050ccaf8b02984b2d3cb0948"

SRC_URI = " \
    file://pciutils-${PV}.tar.gz \
    file://0000-pciutils-2.2.1-idpath.patch \
    file://0001-pciutils-dir-d.patch \
    file://0002-lspci-Adjust-PCI_EXP_DEV2_-to-PCI_EXP_DEVCTL2_-macro.patch \
    file://0003-lspci-Decode-10-Bit-Tag-Requester-Enable.patch \
    file://0004-lspci-Decode-VF-10-Bit-Tag-Requester.patch \
    file://0005-lspci-Update-tests-files-with-VF-10-Bit-Tag-Requeste.patch \
"

# apply patches from poky, to fix configure error
SRC_URI += " \
    file://configure.patch \
"

# file of ids package is /usr/share/hwdata/pci.ids.gz, but datadir is /usr/share/
# update it from FILES_${PN}-ids = "${datadir}/pci.ids*" in poky bb.
FILES_${PN}-ids = "${datadir}/*/pci.ids*"
