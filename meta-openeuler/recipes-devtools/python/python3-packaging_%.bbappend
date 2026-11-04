PV = "24.2"
OPENEULER_LOCAL_NAME = "python-${PYPI_PACKAGE}"

# use openeuler's pkg src; the src repo stores the GitHub tag archive
# (Source0 in the spec), which is named just "24.2.tar.gz" without the
# project prefix
SRC_URI:prepend = "file://24.2.tar.gz "

# We don't have support for python_flit_core.bbclass, so replace the do_compile
do_compile:class-native () {
    cd ${PEP517_SOURCE_PATH}
    nativepython3 -m flit_core.wheel --outdir ${PEP517_WHEEL_PATH} .
}

SRC_URI[sha256sum] = "c448ea78de5134f5002a2aa2bb62a0fb4714bb4ab2d2b00bce8ed6ca22502d5a"
