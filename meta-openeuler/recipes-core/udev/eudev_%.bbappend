OPENEULER_LOCAL_NAME = "oee_archive"

PV = "3.2.14"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
"

