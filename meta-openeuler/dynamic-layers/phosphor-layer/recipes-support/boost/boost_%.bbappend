# main bbfile: meta/recipes-support/boost/boost_1.78.0.bb
PV = "1.83.0"

# modify 0001-Don-t-set-up-arch-instruction-set-flags-we-do-that-o.patch
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# since OpenBMC must use version 1.78.0
SRC_URI = "file://${BOOST_P}.tar.gz \
        file://boost-1.81-graph-Dont-run-performance-test-in-CI.patch \
        file://boost-1.81-random-Update-multiprecision_float_test.cpp-to-not-overflow.patch \
        file://boost-1.81-random-Update-multiprecision_int_test.cpp-to-not-accidental.patch \
        file://boost-1.81-random-test-Add-missing-includes.patch \
        file://boost-1.81-phoenix-Update-avoid-placeholders-uarg1.10-ODR-violates.patch \        
"

SRC_URI[sha256sum] = "c0685b68dd44cc46574cce86c4e17c0f611b15e195be9848dfd0769a0a207628"

S = "${WORKDIR}/${BOOST_P}"

OPENEULER_REPO_NAME = "boost-obmc"
