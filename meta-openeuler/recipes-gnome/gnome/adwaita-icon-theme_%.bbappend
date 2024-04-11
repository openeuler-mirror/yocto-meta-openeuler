PV = "45.0"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
"

DEPENDS += "librsvg"
DEPENDS:remove = "librsvg-native"
