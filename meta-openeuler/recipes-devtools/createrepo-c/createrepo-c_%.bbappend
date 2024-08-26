PV = "1.1.3"

SRC_URI:prepend = "file://createrepo_c-${PV}.tar.gz \
           "

S = "${WORKDIR}/createrepo_c-${PV}"
