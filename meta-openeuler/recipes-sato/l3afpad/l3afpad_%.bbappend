# main bb: yocto-poky/meta/recipes-sato/l3afpad/l3afpad_git.bb
# ref: git://git.toradex.com/meta-lxde.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.8.18.1.11"

SRC_URI = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/l3afpad-${PV}.tar.gz \
"

S = "${WORKDIR}/l3afpad-${PV}"

