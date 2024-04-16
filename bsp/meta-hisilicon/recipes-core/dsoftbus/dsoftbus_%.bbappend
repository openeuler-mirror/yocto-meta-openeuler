# libboundscheck provided by hieulerpi1-user-driver with libsecurec

RDEPENDS:${PN}:remove:hieulerpi1 = "libboundscheck"
DEPENDS:remove:hieulerpi1 = "libboundscheck"

RDEPENDS:${PN}:append:hieulerpi1 = " hieulerpi1-user-driver "
DEPENDS:append:hieulerpi1 = " hieulerpi1-user-driver "
