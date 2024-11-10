# ref: yocto-meta-openembedded/meta-multimedia/recipes-multimedia/libuvc/libuvc.bb

PV = "0.0.7"

SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    "
S = "${WORKDIR}/${BP}"
