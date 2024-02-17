
PV = "1.74.0"

# openeuler src
SRC_URI:prepend = "file://${BP}.tar.xz \
           "

RDEPENDS:${PN}:remove:class-native = "${@['', 'python3-pickle python3-xml']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"
