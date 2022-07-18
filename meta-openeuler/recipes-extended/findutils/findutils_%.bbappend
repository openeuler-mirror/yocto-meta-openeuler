# main bbfile: yocto-poky/meta/recipes-extended/findutils/findutils_4.8.0.bb

# files, patches that come from openeuler
SRC_URI += " \
        file://0001-findutils-leaf-opt.patch \
        file://0001-findutils-xautofs.patch \
"
