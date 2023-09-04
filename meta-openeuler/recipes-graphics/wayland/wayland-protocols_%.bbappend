OPENEULER_SRC_URI_REMOVE = "http git"

# version in src-openEuler
PV = "1.32"

SRC_URI:prepend = "file://wayland-protocols-${PV}.tar.xz \
"
