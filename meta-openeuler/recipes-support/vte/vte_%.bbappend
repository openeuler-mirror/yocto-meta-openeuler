# main bb: yocto-poky/meta/recipes-support/vte/vte_0.66.2.bb
OPENEULER_SRC_URI_REMOVE = "https http git gitsm"
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.66.2"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/vte-${PV}.tar.xz \
"

S = "${WORKDIR}/vte-${PV}"

