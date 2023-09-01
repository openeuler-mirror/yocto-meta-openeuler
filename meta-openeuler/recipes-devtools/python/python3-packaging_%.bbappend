PV = "23.1"
require pypi-src-openeuler.inc

# We don't have support for python_flit_core.bbclass, so replace the do_compile
do_compile:class-native () {
    cd ${PEP517_SOURCE_PATH}
    nativepython3 -m flit_core.wheel --outdir ${PEP517_WHEEL_PATH} .
}
