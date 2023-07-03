# meta-oe/recipes-devtools/yajl/yajl_2.1.0.bb?h=hardknott

OPENEULER_SRC_URI_REMOVE = "git"

SRC_URI:prepend = " \
        file://${PV}.tar.gz \
        file://0001-yajl-2.1.0-pkgconfig-location.patch \
        file://0002-yajl-2.1.0-pkgconfig-includedir.patch \
        file://0003-yajl-2.1.0-test-location.patch \
        file://0004-yajl-2.1.0-dynlink-binaries.patch \
        file://0005-yajl-2.1.0-fix-memory-leak.patch \
        file://0006-fix-memory-leak-of-ctx-root.patch \
        file://0007-add-cmake-option-for-test-and-binary.patch \
        file://backport-CVE-2022-24795.patch \
        file://yajl-assert-error-when-memory-allocation-failed.patch \
	"

S = "${WORKDIR}/${BP}"
