# main bb: yocto-meta-openembedded/meta-oe/recipes-core/mm-common/mm-common_1.0.4.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "1.0.5"

# this patch just for 1.0.4
SRC_URI:remove = " \
        file://0001-meson.build-do-not-ask-for-python-installation-versi.patch \
"

SRC_URI += " \
        file://mm-common-${PV}.tar.xz \
"

S = "${WORKDIR}/mm-common-${PV}"

