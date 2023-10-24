OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "20211108"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

