OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.29.2"

SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${BPN}/pkg-config-${PV}.tar.gz \
           "

SRC_URI[sha256sum] = "8a7b4114765ef4c96cbf02b0be804c0097447461dd76a86c3700c2d241b723ad"
