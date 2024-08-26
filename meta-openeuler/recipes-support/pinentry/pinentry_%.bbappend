
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# not support of libcap from 1.2.1
PACKAGECONFIG:remove = "libcap"
PACKAGECONFIG[libcap] = ""

PV = "1.3.0"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           "

SRC_URI[sha256sum] = "9b3cd5226e7597f2fded399a3bc659923351536559e9db0826981bca316494de"

S = "${WORKDIR}/${BP}"
