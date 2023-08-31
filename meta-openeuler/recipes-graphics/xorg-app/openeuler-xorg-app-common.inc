SRC_URI:remove = "${XORG_MIRROR}/individual/app/${BPN}-${PV}.tar.${SRC_URI_EXT}"

SRC_URI:prepend = "file://${BPN}-${PV}.tar.${SRC_URI_EXT} \
           "

SRC_URI_EXT = "bz2"
