# main bb file: openembedded-core/recipes-devtools/yajl/yajl_2.1.0.bb; branch: kirkstone

SRC_URI_remove = "git://github.com/lloyd/yajl;branch=master;protocol=https \
                  "

SRC_URI_prepend = "file://${PV}.tar.gz \
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

SRC_URI[md5sum] = "6887e0ed7479d2549761a4d284d3ecb0"
SRC_URI[sha256sum] = "3fb73364a5a30efe615046d07e6db9d09fd2b41c763c5f7d3bfb121cd5c5ac5a"

S = "${WORKDIR}/${BP}"
