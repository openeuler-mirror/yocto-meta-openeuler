# main bbfile: yocto-poky/meta/recipes-devtools/libtool/libtool-cross_2.4.6.bb

SRC_URI_remove = "${GNU_MIRROR}/libtool/libtool-${PV}.tar.gz \
"

# apply openeuler source package and patches
SRC_URI_prepend = " \
           file://libtool-${PV}.tar.xz \
           file://libtool-2.4.5-rpath.patch \
           file://libtool-2.4.6-am-1.16-test.patch \
           file://libtool-exit-verbosely-for-fatal-configure-problems.patch \
           file://libtool-fix-GCC-linking-with-specs.patch \
"
