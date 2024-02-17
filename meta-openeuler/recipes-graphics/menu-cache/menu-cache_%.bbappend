# main bb: yocto-poky/meta/recipes-graphics/menu-cache/menu-cache_1.1.0.bb


PV = "1.1.0"

# can't apply from src-openeuler
# menu-cache-1.1.0-0001-Support-gcc10-compilation.patch
SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"
