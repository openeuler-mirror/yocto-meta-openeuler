
PV = "4.0.43"

# openeuler source
SRC_URI:prepend = "file://${BP}.tar.bz2 \
        file://0001-comment-invalid-info-in-conf-file.patch \
           "

S = "${WORKDIR}/${BP}"
