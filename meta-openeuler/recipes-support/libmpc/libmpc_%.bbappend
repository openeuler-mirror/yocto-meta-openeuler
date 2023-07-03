# main bb file: yocto-poky/meta/recipes-support/libmpc/libmpc_1.2.1.bb

PV = "1.2.0"

SRC_URI:remove = "${GNU_MIRROR}/mpc/mpc-${PV}.tar.gz "
SRC_URI:prepend = "file://mpc-${PV}.tar.gz "
