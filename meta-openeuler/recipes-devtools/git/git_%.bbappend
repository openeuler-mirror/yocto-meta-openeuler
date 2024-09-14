# openeuler PV
PV = "2.46.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# 2.41.0 sha256sum
SRC_URI[tarball.sha256sum] = "b138811e16838f669a2516e40f09d50500e1c7fc541b5ab50ce84b98585e5230"

# openeuler SRC_URI
SRC_URI:prepend = "file://${BP}.tar.xz \
                  "

S = "${WORKDIR}/${BP}"
