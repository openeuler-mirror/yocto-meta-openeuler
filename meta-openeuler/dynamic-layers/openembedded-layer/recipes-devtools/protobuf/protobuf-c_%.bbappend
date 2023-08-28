# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/protobuf/protobuf-c_1.4.1.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "1.4.1"
S = "${WORKDIR}/protobuf-c-${PV}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
"

