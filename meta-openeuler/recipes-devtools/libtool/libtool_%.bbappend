# main bbfile: yocto-poky/meta/recipes-devtools/libtool/libtool-cross_2.4.7.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "2.4.7"

# apply openeuler source package and patches
SRC_URI:prepend = "file://libtool-${PV}.tar.xz \
           file://libtool-2.4.5-rpath.patch \
           file://backport-tests-link-order.at-avoid-warning-and-test-failure.patch \
           "
