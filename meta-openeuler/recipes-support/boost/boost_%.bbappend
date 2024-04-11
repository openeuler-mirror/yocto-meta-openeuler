# main bbfile: meta/recipes-support/boost/boost_1.75.0.bb
PV = "1.83.0"

# modify 0001-Don-t-set-up-arch-instruction-set-flags-we-do-that-o.patch
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Do not use remove since this prevents lower versions from being built
# For example, meta-phosphor needs boost 1.78.0 to be built

SRC_URI = " \
        file://${BOOST_P}.tar.gz \
        file://boost-1.81-graph-Dont-run-performance-test-in-CI.patch \
        file://boost-1.81-random-Update-multiprecision_float_test.cpp-to-not-overflow.patch \
        file://boost-1.81-random-Update-multiprecision_int_test.cpp-to-not-accidental.patch \
        file://boost-1.81-random-test-Add-missing-includes.patch \
        file://boost-1.81-phoenix-Update-avoid-placeholders-uarg1.10-ODR-violates.patch \
        "

S = "${WORKDIR}/${BOOST_P}"

# keep consistent with the higher version bb

BJAM_OPTS += "-sICU_PATH=${STAGING_EXECPREFIXDIR}"

