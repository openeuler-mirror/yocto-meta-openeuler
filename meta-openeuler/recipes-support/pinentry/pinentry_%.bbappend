OPENEULER_SRC_URI_REMOVE = "git http https"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# not support of libcap from 1.2.1
PACKAGECONFIG:remove = "libcap"
PACKAGECONFIG[libcap] = ""

PV = "1.2.1"

SRC_URI:prepend = "file://${BPN}-${PV}.tar.bz2 \
           "

S = "${WORKDIR}/${BP}"
