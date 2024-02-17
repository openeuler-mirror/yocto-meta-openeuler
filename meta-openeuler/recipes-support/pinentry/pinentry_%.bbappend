
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# not support of libcap from 1.2.1
PACKAGECONFIG:remove = "libcap"
PACKAGECONFIG[libcap] = ""

PV = "1.2.1"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           "

S = "${WORKDIR}/${BP}"
