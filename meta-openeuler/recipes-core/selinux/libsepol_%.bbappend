# the main bb file: yocto-meta-openeuler/meta-openeuler/recipes-core/selinux/libsepol_3.4.bb

PV = "3.4"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI:prepend = "file://${BP}.tar.gz \
        "

SRC_URI[md5sum] = "55fef291fa5fa5b43bd98e1bc1c3d088"
SRC_URI[sha256sum] = "fc277ac5b52d59d2cd81eec8b1cccd450301d8b54d9dd48a993aea0577cf0336"

S = "${WORKDIR}/${BP}"
