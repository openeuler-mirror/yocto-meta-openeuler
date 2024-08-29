# openeuler version
PV = "1.66"

# openeuler src
SRC_URI:prepend = "file://${BP}.tgz \
                  "

S = "${WORKDIR}/${BP}"
LIC_FILES_CHKSUM = "file://COPYING;md5=5713b4719a66a6527e6301e8f8745877"
