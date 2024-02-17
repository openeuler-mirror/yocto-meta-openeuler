# openeuler version
PV = "1.21.4"

# 1.21.4 inc LIC_FILES_CHKSUM
LIC_FILES_CHKSUM = "file://COPYING;md5=6f65012d1daf98cb09b386cfb68df26b"

# openeuler SRC_URI
SRC_URI:prepend = "file://wget-${PV}.tar.gz \
                  "

# openeuler SRC_URI[sha256sum]
SRC_URI[sha256sum] = "81542f5cefb8faacc39bbbc6c82ded80e3e4a88505ae72ea51df27525bcde04c"

S = "${WORKDIR}/wget-${PV}"
