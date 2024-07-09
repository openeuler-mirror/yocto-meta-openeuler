# main bb: meta-wayland/recipes-support/wlr-randr/wlr-randr_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.4.1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/v${PV}.tar.gz \
"

S = "${WORKDIR}/wlr-randr-v${PV}"

