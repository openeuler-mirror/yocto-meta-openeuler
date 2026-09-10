# Upstream recipe: yocto-poky/meta/recipes-devtools/python/python3-pycairo_1.23.0.bb
# Source: https://atomgit.com/src-openeuler/pycairo (1.24.0)
# 1.24.0 is the closest available version to the upstream 1.23.0; the license
# files and the meson requirement (>= 0.56.0) are unchanged, so the recipe's
# LIC_FILES_CHKSUM stays valid. The pkgconfig-requires fix
# (pycairo-use-virtual-dependency-for-pkgconfig.patch) only exists on master
# and is not needed here
PV = "1.24.0"

OPENEULER_LOCAL_NAME = "pycairo"

SRC_URI:prepend = " \
    file://pycairo-${PV}.tar.gz \
"

SRC_URI[sha256sum] = "1444d52f1bb4cc79a4a0c0fe2ccec4bd78ff885ab01ebe1c0f637d8392bcafb6"
