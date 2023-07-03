# main bbfile: meta-oe/recipes-support/uthash/uthash_2.3.0.bb?h=hardknott

PV = "2.1.0"

# modify LICENSE checksum
LIC_FILES_CHKSUM = "file://LICENSE;md5=a2513f7d2291df840527b76b2a8f9718"

OPENEULER_SRC_URI_REMOVE = "git"

SRC_URI:prepend = " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/uthash-${PV}"
