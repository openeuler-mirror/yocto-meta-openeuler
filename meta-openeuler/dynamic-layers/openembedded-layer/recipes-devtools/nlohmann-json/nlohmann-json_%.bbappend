# use a newer stable version 3.12.0 from oee-archive
inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "nlohmann-json"

PV = "3.12.0"

LIC_FILES_CHKSUM = "file://LICENSE.MIT;md5=3b489645de9825cca5beeb9a7e18b6eb"

SRC_URI += " \
    file://v${PV}.tar.gz \
"

S = "${WORKDIR}/json-${PV}"
