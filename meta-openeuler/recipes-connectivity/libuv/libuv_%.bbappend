# main bb file: yocto-poky/meta/recipes-connectivity/libuv/libuv_1.44.2.bb

# version in openEuler
PV = "1.52.1"

LIC_FILES_CHKSUM = "file://LICENSE;md5=74b6f2f7818a4e3a80d03556f71b129b"

# apply openEuler source package
SRC_URI:prepend = "file://${BPN}-v${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-v${PV}"
