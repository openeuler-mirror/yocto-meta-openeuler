PV = "1.0.1"

SRC_URI:prepend = "file://createrepo_c-${PV}.tar.gz \
                  file://createrepo_c-Add-sw64-architecture.patch \
           "

S = "${WORKDIR}/createrepo_c-${PV}"
