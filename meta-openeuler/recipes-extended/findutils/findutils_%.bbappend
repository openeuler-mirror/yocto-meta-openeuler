# main bbfile: yocto-poky/meta/recipes-extended/findutils/findutils_4.8.0.bb

PV = "4.8.0"

# files, patches that come from openeuler
SRC_URI = " \
    file://findutils-${PV}.tar.xz \
    file://backport-findutils-xautofs.patch \
    file://backport-findutils-leaf-opt.patch \
    file://backport-maint-fix-typo-in-comments-in-parser.c.patch \
"

SRC_URI[sha256sum] = "a2bfb8c09d436770edc59f50fa483e785b161a3b7b9d547573cb08065fd462fe"
