# main bb file: yocto-poky/meta/recipes-devtools/i2c-tools/i2c-tools_4.3.bb

PV = "4.3"

S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:remove = "${KERNELORG_MIRROR}/software/utils/i2c-tools/${BP}.tar.gz"
SRC_URI:prepend = "file://${BPN}-${PV}.tar.xz \
                   "
SRC_URI[sha256sum] = "1f899e43603184fac32f34d72498fc737952dbc9c97a8dd9467fadfdf4600cf9"
