PV = "23.5.26"

LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI = " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"
