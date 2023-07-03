# main bbfile: yocto-meta-openembedded/meta-oe/recipes-test/googletest/googletest_git.bb

OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_LOCAL_NAME = "gtest"

# version in openEuler
PV = "1.8.1"

S = "${WORKDIR}/googletest-release-${PV}"
SRC_URI:append = " \
        file://${OPENEULER_LOCAL_NAME}/release-${PV}.tar.gz \
        file://${OPENEULER_LOCAL_NAME}/gtest-1.8.1-null-pointer.patch \
        file://${OPENEULER_LOCAL_NAME}/gtest-PR1839-Fix-Python3-support.patch \
        file://${OPENEULER_LOCAL_NAME}/gtest-1.8.1-libversion.patch \
        file://${OPENEULER_LOCAL_NAME}/gtest-1.8.1-add-missing-pkgconfig-requires.patch \
        file://${OPENEULER_LOCAL_NAME}/0001-Googletest-export.patch \
        "

SRC_URI:remove = "file://0001-work-around-GCC-6-11-ADL-bug.patch \
"
