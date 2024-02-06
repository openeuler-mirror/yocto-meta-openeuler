# libboundscheck provided by hibot-user-driver with libsecurec

RDEPENDS:${PN}:remove:sd3403 = "libboundscheck"
DEPENDS:remove:sd3403 = "libboundscheck"

RDEPENDS:${PN}:append:sd3403 = " hibot-user-driver "
DEPENDS:append:sd3403 = " hibot-user-driver "
