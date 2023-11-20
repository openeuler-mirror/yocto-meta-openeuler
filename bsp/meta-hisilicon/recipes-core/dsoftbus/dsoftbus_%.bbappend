# libboundscheck provided by hibot-user-driver with libsecurec

RDEPENDS:${PN}:remove = "libboundscheck"
DEPENDS:remove = "libboundscheck"

RDEPENDS:${PN}:append = " hibot-user-driver "
DEPENDS:append = " hibot-user-driver "
