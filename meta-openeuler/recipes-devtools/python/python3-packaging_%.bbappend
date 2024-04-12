PV = "23.2"
require pypi-src-openeuler.inc

# We don't have support for python_flit_core.bbclass, so replace the do_compile
do_compile:class-native () {
    cd ${PEP517_SOURCE_PATH}
    nativepython3 -m flit_core.wheel --outdir ${PEP517_WHEEL_PATH} .
}

SRC_URI[sha256sum] = "048fb0e9405036518eaaf48a55953c750c11e1a1b68e0dd1a9d62ed0c092cfc5"
