# openeuler version
PV = "1.64"

# openeuler src
SRC_URI:prepend = "file://diffstat-${PV}.tgz \
                  "

S = "${WORKDIR}/diffstat-${PV}"
