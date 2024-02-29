# main bbfile: meta/recipes-support/boost/boost_1.75.0.bb
PV = "1.81.0"

# modify 0001-Don-t-set-up-arch-instruction-set-flags-we-do-that-o.patch
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# remove conflict files
SRC_URI:remove = " \
        file://boost-CVE-2012-2677.patch \
        file://0001-fiber-libs-Define-SYS_futex-if-it-does-not-exist.patch \
        file://de657e01635306085488290ea83de541ec393f8b.patch \
        file://0001-futex-fix-build-on-32-bit-architectures-using-64-bit.patch \
        file://0001-Don-t-skip-install-targets-if-there-s-build-no-in-ur.patch \
"

SRC_URI:prepend = " \
        file://${BOOST_P}.tar.gz \
        file://boost-1.80-outcome-Stop-Boost-regression-tests-complaining-about-no-test-tree.patch \
        file://boost-1.81-graph-Dont-run-performance-test-in-CI.patch \
        file://boost-1.81-random-Update-multiprecision_float_test.cpp-to-not-overflow.patch \
        file://boost-1.81-random-Update-multiprecision_int_test.cpp-to-not-accidental.patch \
        file://boost-1.81-random-test-Add-missing-includes.patch \
        "

SRC_URI[sha256sum] = "205666dea9f6a7cfed87c7a6dfbeb52a2c1b9de55712c9c1a87735d7181452b6"

S = "${WORKDIR}/${BOOST_P}"

# keep consistent with the higher version bb

BJAM_OPTS += "-sICU_PATH=${STAGING_EXECPREFIXDIR}"

# from boost 1.81.0, the boost-url is synthesized into boost
# so we need to add the url to the boost_libs
# and no longer use the boost-url
BOOST_LIBS += "url"
