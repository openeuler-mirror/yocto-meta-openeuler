# the main bb file: yocto-poky/meta/recipes-support/iso-codes/iso-codes_4.13.0.bb
OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "4.7.0"

SRC_URI = "file://${BPN}-${BP}.tar.gz \
"

S = "${WORKDIR}/${BPN}-${BP}"

SRC_URI[sha256sum] = "221686c738c99efe4054c87913fbf0d2e70253b1e83bd7383a2cb883992572ed"
