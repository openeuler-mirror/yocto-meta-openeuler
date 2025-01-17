# main bbfile: yocto-meta-openembedded/meta-oe/recipes-test/googletest/googletest_git.bb

OPENEULER_LOCAL_NAME = "gtest"

# version in openEuler
PV = "1.14.0"

S = "${WORKDIR}/${BP}"
SRC_URI:append = " \
        file://v${PV}.tar.gz \
"

SRC_URI:remove = " \
        file://0001-work-around-GCC-6-11-ADL-bug.patch \
"

# The following configuration is for version 1.14.0

inherit pkgconfig

# allow for shared libraries, but do not default to them
#
PACKAGECONFIG[shared] = "-DBUILD_SHARED_LIBS=ON,-DBUILD_SHARED_LIBS=OFF,,"

CXXFLAGS:append = " -fPIC"

# -staticdev will not be implicitly put into an SDK, so we add an rdepend
# if we are not building shared libraries
#
RDEPENDS:${PN}-dev += "${@bb.utils.contains("PACKAGECONFIG","shared","","${PN}-staticdev",d)}"
SRC_URI[sha256sum] = "8ad4a4d328dce9226a23158420548f4dcb4303edd2cd4068e03d1385701d9080"
