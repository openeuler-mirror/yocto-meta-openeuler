
PV = "1.1.1"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
