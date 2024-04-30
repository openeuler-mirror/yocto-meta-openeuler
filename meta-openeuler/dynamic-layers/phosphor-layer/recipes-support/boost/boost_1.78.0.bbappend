# main bbfile: meta/recipes-support/boost/boost_1.78.0.bb
PV = "1.78.0"

# modify 0001-Don-t-set-up-arch-instruction-set-flags-we-do-that-o.patch
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# since OpenBMC must use version 1.78.0
SRC_URI = " \
        file://${BOOST_P}.tar.gz \
        file://boost-1.78-pool-fix-integer-overflows-in-pool-ordered_malloc.patch \
        file://boost-1.78-locale-Fix-access-to-first-element-of-empty-vector.patch \
        file://boost-1.77-type_erasure-remove-boost-system-linkage.patch \
        file://boost-1.78-build-Don-t-skip-install-targets-if-there-s-build-no-in-ureqs.patch \
        file://boost-1.78-filesystem-Added-protection-for-CVE-2022-21658.patch \
        file://boost-1.78-filesystem-Use-O_NONBLOCK-instead-of-O_NDELAY.patch \
        file://boost-1.78-python-Update-call_method-hpp.patch \
        "

SRC_URI[sha256sum] = "205666dea9f6a7cfed87c7a6dfbeb52a2c1b9de55712c9c1a87735d7181452b6"

S = "${WORKDIR}/${BOOST_P}"

OPENEULER_REPO_NAME = "boost-obmc"
