
PV = "1.15.2"

# from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:prepend = " file://librepo-${PV}.tar.gz \
           "

S = "${WORKDIR}/${BP}"
