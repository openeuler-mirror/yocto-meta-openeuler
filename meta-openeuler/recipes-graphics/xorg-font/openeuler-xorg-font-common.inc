# use openeuler src

SRC_URI:prepend = "file://${XORG_PN}-${PV}.tar.${SRC_URI_EXT} \
           "

SRC_URI_EXT = "bz2"
