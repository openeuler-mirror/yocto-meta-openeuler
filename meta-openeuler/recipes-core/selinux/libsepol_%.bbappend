# the main bb file: yocto-meta-openeuler/meta-openeuler/recipes-core/selinux/libsepol_3.4.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "3.5"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=a6f89e2100d9b6cdffcea4f398e37343"

SRC_URI:remove = "file://0001-libsepol-fix-validation-of-user-declarations-in-modu.patch"

SRC_URI:prepend = "file://${BP}.tar.gz \
        "

S = "${WORKDIR}/${BP}"
