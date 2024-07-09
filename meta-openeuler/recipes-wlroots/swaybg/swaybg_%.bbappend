# main bb: meta-wayland/recipes-support/swaybg/swaybg_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "1.2.1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/v${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"

