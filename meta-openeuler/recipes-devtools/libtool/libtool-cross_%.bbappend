# main bbfile: yocto-poky/meta/recipes-devtools/libtool/libtool-cross_2.4.6.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PV = "2.4.7"

SRC_URI:remove = "${GNU_MIRROR}/libtool/libtool-${PV}.tar.gz \
           file://unwind-opt-parsing.patch \
"

# apply openeuler source package and patches
SRC_URI:prepend = " \
           file://libtool-${PV}.tar.xz \
           file://libtool-2.4.5-rpath.patch \
"
