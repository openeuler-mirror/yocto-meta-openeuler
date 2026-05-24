PV = "24.2"
require pypi-src-openeuler.inc

# We don't have support for python_flit_core.bbclass, so replace the do_compile
do_compile:class-native () {
    cd ${PEP517_SOURCE_PATH}
    nativepython3 -m flit_core.wheel --outdir ${PEP517_WHEEL_PATH} .
}

# SP4 tarball is named 24.2.tar.gz, not packaging-24.2.tar.gz
SRC_URI:remove = "file://packaging-${PV}.tar.gz"
SRC_URI:prepend = "file://${PV}.tar.gz "

SRC_URI[sha256sum] = "c448ea78de5134f5002a2aa2bb62a0fb4714bb4ab2d2b00bce8ed6ca22502d5a"

# nativepython3 sysconfig returns native sysroot paths; use direct unzip instead
DEPENDS:append = " unzip-native"
do_install() {
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    unzip -d ${D}${PYTHON_SITEPACKAGES_DIR} ${PEP517_WHEEL_PATH}/*.whl
}
