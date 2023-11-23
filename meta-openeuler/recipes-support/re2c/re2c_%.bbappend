OPENEULER_SRC_URI_REMOVE = "https"

PV = "2.0.3"

# upstream src and patches
SRC_URI:prepend = " file://re2c-${PV}.tar.xz \
           "
