OPENEULER_SRC_URI_REMOVE = "git"

PV = "0.20.1"

SRC_URI:prepend = "file://createrepo_c-${PV}.tar.gz \
           "

S = "${WORKDIR}/createrepo_c-${PV}"
