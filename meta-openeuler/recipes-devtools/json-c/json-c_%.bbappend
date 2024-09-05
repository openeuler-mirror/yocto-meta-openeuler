# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

# json-c version in openEuler
PV = "0.17-20230812"

# openeuler src package
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        "

SRC_URI[md5sum] = "6d724389b0a08c519d9dd6e2fac7efb8"
SRC_URI[sha256sum] = "10c69b3cb5851f8bde67264ff7d8d679abe310441789e78d4b8225d0d9b09504"

S = "${WORKDIR}/json-c-json-c-${PV}"
