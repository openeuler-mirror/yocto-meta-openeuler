
PV = "1.5.10"

# openeuler patch
SRC_URI:prepend = "file://${BP}.tar.xz \
           file://add-GLIBC_2.27-to-test-versions-for-riscv.patch \
           "

SRC_URI[sha256sum] = "072cda4b59dd098bba8c2363a6247299db1fa89411dc221c8b81b8ee8192e623"

S = "${WORKDIR}/${BP}"
