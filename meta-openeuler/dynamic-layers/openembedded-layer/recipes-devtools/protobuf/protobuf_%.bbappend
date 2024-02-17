# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/protobuf/protobuf_3.21.12.bb

# version in openEuler
PV = "3.19.6"
S = "${WORKDIR}/protobuf-${PV}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://protobuf-all-${PV}.tar.gz \
    file://0001-add-secure-compile-option-in-Makefile.patch \
    file://0002-add-secure-compile-fs-check-in-Makefile.patch \
"

