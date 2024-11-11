inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "rt-tests"

SRC_URI:append = " \
    file://rt-tests-${PV}.tar.gz \
    "

S = "${WORKDIR}/rt-tests-${PV}"
