PV = "1.0.4"

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

LIC_FILES_CHKSUM_remove = "file://${WORKDIR}/git/main.cpp;beginline=1;endline=26;md5=93b83ece006c9e76b9fca80c3aecb169"
LIC_FILES_CHKSUM_prepend = "file://main.cpp;beginline=1;endline=26;md5=93b83ece006c9e76b9fca80c3aecb169"

SRC_URI = "file://${BP}.tar.gz"

S = "${WORKDIR}/${BP}"
