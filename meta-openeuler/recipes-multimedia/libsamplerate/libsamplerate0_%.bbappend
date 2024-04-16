OPENEULER_LOCAL_NAME = "libsamplerate"

PV = "0.2.2"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${OPENEULER_LOCAL_NAME}-${PV}.tar.xz \
"

