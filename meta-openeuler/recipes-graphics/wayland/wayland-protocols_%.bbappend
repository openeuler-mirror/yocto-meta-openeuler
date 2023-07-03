# version in src-openEuler
PV = "1.25"

SRC_URI:remove = "https://wayland.freedesktop.org/releases/${BPN}-${PV}.tar.xz \
"

SRC_URI += "file://wayland-protocols-${PV}.tar.xz \
"

SRC_URI[md5sum] = "0c192bf32de09ec30de4a82d1c65329c"
