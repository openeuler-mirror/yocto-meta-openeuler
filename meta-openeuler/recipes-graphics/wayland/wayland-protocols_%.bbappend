# bbfile: yocto-poky/meta/recipes-graphics/wayland/wayland-protocols_1.25.bb
# version in src-openEuler

PV = "1.33"

UPSTREAM_CHECK_URI = "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/tags"

SRC_URI = "file://${BP}.tar.bz2 \
"

SRC_URI[sha256sum] = "622754e38cf70e9e02700e2df22cbd1257e523e0cc22004f1ece409719823da5"
