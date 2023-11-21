# main bb: meta-openembedded/tree/meta-oe/recipes-graphics/cglm/cglm_0.9.1.bb
# from https://git.openembedded.org/
OPENEULER_SRC_URI_REMOVE = "https http git"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.9.1"

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/${BPN}/cglm-${PV}.tar.gz \
"

S = "${WORKDIR}/cglm-${PV}"


