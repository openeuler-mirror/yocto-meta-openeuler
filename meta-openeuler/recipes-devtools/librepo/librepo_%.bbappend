
PV = "1.15.2"

# from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:prepend = " file://${BP}.tar.gz \
           "

S = "${WORKDIR}/${BP}"
