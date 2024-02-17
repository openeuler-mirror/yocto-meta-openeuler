
PV = "0.20.1"

SRC_URI:prepend = "file://createrepo_c-${PV}.tar.gz \
           "

S = "${WORKDIR}/createrepo_c-${PV}"
