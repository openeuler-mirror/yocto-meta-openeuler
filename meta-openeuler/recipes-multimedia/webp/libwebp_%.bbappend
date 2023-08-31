# the main bb file: yocto-poky/meta/recipes-multimedia/webp/libwebp_1.2.4.bb

PV = "1.3.1"

SRC_URI:remove = " \
    http://downloads.webmproject.org/releases/webp/${BP}.tar.gz \
"

SRC_URI:append = " \
    file://${BP}.tar.gz \
"

SRC_URI[sha256sum] = "64ac4614db292ae8c5aa26de0295bf1623dbb3985054cb656c55e67431def17c"
