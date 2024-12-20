
PV = "1.15.2"

# from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:prepend = " file://${BP}.tar.gz \
  file://backport-Fix-a-memory-leak-in-select_next_target.patch \
           "

S = "${WORKDIR}/${BP}"
