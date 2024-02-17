PV = "3.11.2"

LIC_FILES_CHKSUM = "file://LICENSE.MIT;md5=f969127d7b7ed0a8a63c2bbeae002588"

SRC_URI += " \
    file://v${PV}.tar.gz \
"

S = "${WORKDIR}/json-${PV}"
