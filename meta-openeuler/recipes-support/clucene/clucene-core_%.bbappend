# source bb: yocto-meta-openeuler/meta-openeuler/recipes-support/clucene/clucene-core_2.3.3.4.bb
SRC_URI:remove = " \
    ${SOURCEFORGE_MIRROR}/project/clucene/${BPN}-unstable/2.3/${BPN}-${PV}.tar.gz \
    file://0003-align-pkg-config.patch \
"

SRC_URI:prepend = " \
    file://${BPN}-${PV}-e8e3d20.tar.xz\
    file://0000-clucene-core-2.3.3.4-pkgconfig.patch \
    file://0002-Fix-missing-include-time.h.patch \
"

