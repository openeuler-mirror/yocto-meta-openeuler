PV = "0.4.1"

SRC_URI:remove = "http://xcb.freedesktop.org/dist/${BPN}-${PV}.tar.bz2"

SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
           "
