# main bb file: yocto-poky/meta/recipes-extended/net-tools/net-tools_2.10.bb

PV = "2.10"

S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:remove = "git://git.code.sf.net/p/net-tools/code;protocol=https;branch=master \"
SRC_URI:prepend = "file://${BPN}-${PV}.tar.xz \
        file://backport-net-tools-cycle.patch \
        file://backport-net-tools-man.patch \
        "
# ether-wake.c patches from openeuler not allpy for embedded
