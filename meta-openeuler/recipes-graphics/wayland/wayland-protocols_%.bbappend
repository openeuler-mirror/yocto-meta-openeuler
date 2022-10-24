# version in src-openEuler
PV = "1.25"

SRC_URI[md5sum] = "0c192bf32de09ec30de4a82d1c65329c"
SRC_URI[sha256sum] = "f1ff0f7199d0a0da337217dd8c99979967808dc37731a1e759e822b75b571460"

# use meson build instead of autotools build in version 1.25
inherit meson

# add configuration in later version
# http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-graphics/wayland/wayland-protocols_1.25.bb?h=kirkstone
EXTRA_OEMESON += "-Dtests=false"