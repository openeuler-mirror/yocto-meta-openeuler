OPENEULER_SRC_URI_REMOVE = "git"

OPENEULER_LOCAL_NAME = "oee_archive"


SRC_URI:append = " \
    file://${OPENEULER_LOCAL_NAME}/rt-tests/rt-tests-${PV}.tar.gz \
    "

S = "${WORKDIR}/rt-tests-${PV}"
