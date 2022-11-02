# main bbfile: yocto-poky/meta/recipes-extended/findutils/findutils_4.8.0.bb

# files, patches that come from openeuler
SRC_URI += " \
        file://backport-findutils-leaf-opt.patch \
        file://backport-findutils-xautofs.patch \
        file://backport-maint-fix-typo-in-comments-in-parser.c.patch \
"
