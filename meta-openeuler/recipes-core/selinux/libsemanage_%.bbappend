
PV = "3.5"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=a6f89e2100d9b6cdffcea4f398e37343"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://fix-test-failure-with-secilc.patch \
        "

S = "${WORKDIR}/${BP}"
