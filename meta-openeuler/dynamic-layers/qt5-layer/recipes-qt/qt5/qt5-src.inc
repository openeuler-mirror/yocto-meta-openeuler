# main bbfile: meta-qt5/recipes-qt/qt5/${BPN}_git.bb

OPENEULER_REPO_NAME = "qt5-${BPN}"

PV = "5.15.2"

SRC_URI:prepend = "file://${BPN}-everywhere-src-${PV}.tar.xz \
"

# Use the source packages from src-openEuler, remove patch conflict with openeuler
SRC_URI:remove = " \
        ${QT_GIT}/${QT_MODULE}.git;name=${QT_MODULE};${QT_MODULE_BRANCH_PARAM};protocol=${QT_GIT_PROTOCOL} \
"

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the src-openEuler source package,
# we need to re-specify it
S = "${WORKDIR}/${BPN}-everywhere-src-${PV}"
