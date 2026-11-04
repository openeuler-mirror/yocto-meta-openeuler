
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# COPYING checksum matches the 1.2.1 base recipe (cbbd794e...)

# not support of libcap from 1.2.1
PACKAGECONFIG:remove = "libcap"
PACKAGECONFIG[libcap] = ""

PV = "1.2.1"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           "

SRC_URI[sha256sum] = "457a185e5a85238fb945a955dc6352ab962dc8b48720b62fc9fa48c7540a4067"

S = "${WORKDIR}/${BP}"
