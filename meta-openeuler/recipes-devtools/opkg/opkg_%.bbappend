OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.5.0"

# from oee_archive
SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
"
