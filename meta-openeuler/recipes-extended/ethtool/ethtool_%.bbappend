PV = "5.19"

SRC_URI:remove = "${KERNELORG_MIRROR}/software/network/ethtool/ethtool-${PV}.tar.gz"

# ptest patch: avoid_parallel_tests.patch
SRC_URI:prepend = "file://${BP}.tar.xz \
           "

SRC_URI[sha256sum] = "3b752a3329827907ac3812f2831dfecf51c8c41c55d2d69cfb9c53ca06449fc6"
