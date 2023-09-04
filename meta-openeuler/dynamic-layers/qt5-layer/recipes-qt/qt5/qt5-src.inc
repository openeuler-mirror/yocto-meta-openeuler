# main bbfile: meta-qt5/recipes-qt/qt5/${BPN}_git.bb

PV = "5.15.10"

OPENEULER_SRC_URI_REMOVE = "http git"

SRC_URI:prepend = "file://${BPN}-everywhere-opensource-src-${PV}.tar.xz \
"

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the src-openEuler source package,
# we need to re-specify it
S = "${WORKDIR}/${BPN}-everywhere-src-${PV}"
