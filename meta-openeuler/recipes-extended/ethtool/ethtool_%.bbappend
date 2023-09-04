# the main bb file: yocto-poky/meta/recipes-extended/ethtool/ethtool_5.16.bb

PV = "6.4"

SRC_URI:remove = "${KERNELORG_MIRROR}/software/network/ethtool/ethtool-${PV}.tar.gz"

# ptest patch: avoid_parallel_tests.patch
SRC_URI:prepend = "file://${BP}.tar.xz \
           "

SRC_URI[sha256sum] = "5eaa083e8108e1dd3876b2c803a1942a2763942715b7f6eb916e189adbb44972"

RDEPENDS:${PN}-ptest += "bash"
