# main bb: meta-wayland/recipes-support/kanshi/kanshi_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "1.7.0"

DEPENDS += "libscfg"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/v${PV}.tar.gz \
"

S = "${WORKDIR}/kanshi-v${PV}"
