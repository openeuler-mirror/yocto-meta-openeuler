# main bb: meta-wayland/recipes-extended/libliftoff/libliftoff_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "v0.4.1"

SRC_URI = "file://${OPENEULER_LOCAL_NAME}/${BPN}/libliftoff-${PV}.tar.gz \
"

S = "${WORKDIR}/libliftoff-${PV}"

