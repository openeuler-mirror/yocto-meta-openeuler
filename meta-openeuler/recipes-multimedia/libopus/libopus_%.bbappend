# the main bb file: yocto-meta-openembedded/meta-oe/recipes-multimedia/libopus/libopus_1.3.1.bb

PV = "1.4"

SRC_URI:prepend = " \
    file://opus-${PV}.tar.gz \
"

S = "${WORKDIR}/opus-${PV}"

