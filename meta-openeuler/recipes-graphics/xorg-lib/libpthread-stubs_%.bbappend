# openeuler PV
PV = "0.4"

OPENEULER_LOCAL_NAME = "oee_archive"

# upstream source
SRC_URI:prepend = " \
            file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.bz2  \
           "
