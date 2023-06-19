# 2.44 require glib2-native update
PV = "2.42.0"

# openeuler tar name
OPENEULER_BP = "AT_SPI2_CORE_2_42_0"

OPENEULER_SRC_URI_REMOVE = "https"

SRC_URI:prepend = "file://${OPENEULER_BP}.tar.gz \
           "

SRC_URI[sha256sum] = "4b5da10e94fa3c6195f95222438f63a0234b99ef9df772c7640e82baeaa6e386"

S = "${WORKDIR}/${BPN}-${OPENEULER_BP}"
