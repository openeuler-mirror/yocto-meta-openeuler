# source bb file: yocto-poky/meta/recipes-extended/diffutils/diffutils_3.7.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "3.8"

# do not use any patch from openEuler community for this package
# these patches will cause compilation error
SRC_URI += " \
    file://${BP}.tar.xz \
"
