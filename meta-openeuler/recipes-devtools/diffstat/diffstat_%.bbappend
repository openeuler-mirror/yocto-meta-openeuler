# openeuler version
PV = "1.64"

# openeuler src
SRC_URI:prepend = "file://${BP}.tgz \
                  "

S = "${WORKDIR}/${BP}"
