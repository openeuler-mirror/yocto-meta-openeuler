OPENEULER_LOCAL_NAME = "oee_archive"

PV = "master_next"

SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
    "

S = "${WORKDIR}/${BP}"
