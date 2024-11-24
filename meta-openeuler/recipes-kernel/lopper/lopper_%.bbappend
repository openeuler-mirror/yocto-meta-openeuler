inherit oee-archive

PV = "master_next"

SRC_URI = " \
    file://${BP}.tar.gz \
    "

S = "${WORKDIR}/${BP}"
