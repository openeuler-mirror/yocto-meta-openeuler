# main bbfile: yocto-poky/meta/recipes-devtools/libtool/libtool-cross_2.4.6.bb

OPENEULER_SRC_URI_REMOVE = "https"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PV = "2.4.7"

SRC_URI_remove = "file://unwind-opt-parsing.patch \
"

# apply openeuler source package and patches
SRC_URI_prepend = " \
           file://libtool-${PV}.tar.xz \
           file://libtool-2.4.5-rpath.patch \
"
