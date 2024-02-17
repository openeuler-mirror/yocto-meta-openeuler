
PV = "2.4.7"

# apply openeuler source package and patches
SRC_URI:prepend = "file://libtool-${PV}.tar.xz \
"

SRC_URI:prepend:class-target = "file://libtool-2.4.5-rpath.patch \
           file://backport-tests-link-order.at-avoid-warning-and-test-failure.patch \
           "
