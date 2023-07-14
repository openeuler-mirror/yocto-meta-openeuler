SUMMARY = "SuiteSparse is a suite of sparse matrix algorithms"
DESCRIPTION = "SuiteSparse is a suite of sparse matrix algorithms, including: UMFPACK(multifrontal LU factorization), CHOLMOD(supernodal Cholesky, with CUDA acceleration), SPQR(multifrontal QR) and many other packages."

LIC_FILES_CHKSUM = "file://../LICENSE.txt;md5=5fa987762101f748a6cdd951b64ffc6b"

SRC_URI = "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-5.4.0.tar.gz"

LICENSE = "BSD-3-Clause"

DEPENDS = " \
    suitesparse-config \
"
inherit ros_distro_humble

S = "${WORKDIR}/SuiteSparse-${PV}/BTF"

EXTRA_OEMAKE = "CC='${CC}'"

do_compile() {
    # build only the library, not the demo
    oe_runmake library
}

do_install() {
    oe_runmake install INSTALL=${D}${prefix}
}

DEPENDS:append:class-target = " chrpath-replacement-native"
do_install:append() {
    chrpath --delete ${D}${libdir}/*${SOLIBS}
}

