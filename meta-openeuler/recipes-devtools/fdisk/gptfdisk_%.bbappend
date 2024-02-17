# openeuler PV
PV = "1.0.8"

OPENEULER_LOCAL_NAME = "oee_archive"

# upstream source
SRC_URI:prepend = " \
            file://${OPENEULER_LOCAL_NAME}/${BPN}/gptfdisk-${PV}.tar.gz  \
           "
