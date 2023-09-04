# the main bb file: yocto-poky/meta/recipes-support/iso-codes/iso-codes_4.13.0.bb

PV = "4.15.0"

SRC_URI = "file://${BPN}-v${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-v${PV}"

SRC_URI[sha256sum] = "b83b54b9d7dd6eb877380b3ec46f370b05daf2cbfa131c612f03598d654c0ef8"

BBCLASSEXTEND += "native"
