
PV = "0.8.2"

SRC_URI:remove = "file://cve-2022-0175.patch \
           "

# openeuler patch
SRC_URI:prepend = "file://${BPN}-${BP}.tar.gz \
           "

S = "${WORKDIR}/${BPN}-${BP}"
