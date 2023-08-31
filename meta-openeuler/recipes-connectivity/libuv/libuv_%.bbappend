# main bb file: yocto-poky/meta/recipes-connectivity/libuv/libuv_1.44.2.bb

# version in openEuler
PV = "1.44.2"

LIC_FILES_CHKSUM = "file://LICENSE;md5=ad93ca1fffe931537fcf64f6fcce084d"

SRC_URI:remove = "git://github.com/libuv/libuv.git;branch=v1.x;protocol=https \
"

# apply openEuler source package
SRC_URI:prepend = "file://${BPN}-v${PV}.tar.gz \
        file://backport-Skip-some-tests.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"
