# main bbfile: yocto-poky/meta/recipes-extended/findutils/findutils_4.8.0.bb

PV = "4.10.0"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz \
        file://0001-findutils-xautofs.patch \
        file://findutils-4.5.15-no-locate.patch \
"

SRC_URI[sha256sum] = "1387e0b67ff247d2abde998f90dfbf70c1491391a59ddfecb8ae698789f0a4f5"

ASSUME_PROVIDE_PKGS = "findutils"
