# main bbfile: yocto-poky/meta/recipes-extended/findutils/findutils_4.8.0.bb

PV = "4.9.0"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz \
        file://0001-findutils-xautofs.patch \
"

SRC_URI[sha256sum] = "a2bfb8c09d436770edc59f50fa483e785b161a3b7b9d547573cb08065fd462fe"
