# the main bb file: yocto-poky/meta/recipes-support/iso-codes/iso-codes_4.13.0.bb

PV = "4.16.0"

SRC_URI = "file://${BPN}-v${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-v${PV}"

SRC_URI[sha256sum] = "7c990fc39a05975bedb0175e3ff09fc383048815f68b462abbf055a8032e66cc"

BBCLASSEXTEND += "native"
