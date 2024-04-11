# main bb file: yocto-poky/meta/recipes-extended/net-tools/net-tools_2.10.bb

PV = "2.10"

S = "${WORKDIR}/${BP}"

# ether-wake.c patches from openeuler not allpy for embedded
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://backport-net-tools-cycle.patch \
        file://backport-net-tools-man.patch \
        "
