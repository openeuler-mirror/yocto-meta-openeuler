# main bb file: yocto-poky/meta/recipes-support/libmpc/libmpc_1.2.1.bb

PV = "1.3.1"

SRC_URI:prepend = "file://mpc-${PV}.tar.gz "

SRC_URI[sha256sum] = "98bde101597442b2a82f50ab263da3ef546f095f44cfcf39b4b3e6ae594ee712"
