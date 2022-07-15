SRC_URI[sha256sum] = "2432e7a2e12000502d36cf769ab6e5a0cf4931e5050ccaf8b02984b2d3cb0948"

SRC_URI = " \
    file://pciutils-${PV}.tar.gz \
    file://0000-pciutils-2.2.1-idpath.patch \
    file://0001-pciutils-dir-d.patch \
"

# apply patches from poky, to fix configure error
SRC_URI += " \
    file://configure.patch \
"

do_install_append() {
    # delete useless files
    rm -rf ${D}/usr/share/hwdata/
}
