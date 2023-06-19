PV = "2.38.0"

# openeuler tar name
OPENEULER_BP = "AT_SPI2_ATK_2_38_0"

OPENEULER_SRC_URI_REMOVE = "https"

SRC_URI:prepend = "file://${OPENEULER_BP}.tar.gz \
           file://backport-fix-test-memory-leak.patch \
           file://backport-also-fix-ref-leak-in-try_get_root.patch \
           "

SRC_URI[sha256sum] = "95f10c80834d3811938153199da671967ee3c8f378883ed3f6ddeee1d316d3e4"

S = "${WORKDIR}/${BPN}-${OPENEULER_BP}"
