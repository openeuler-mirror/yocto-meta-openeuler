# main bb file: yocto-poky/meta/recipes-graphics/wayland/weston_9.0.0.bb

PV = "8.0.0"

SRC_URI_remove = "file://0001-tests-include-fcntl.h-for-open-O_RDWR-O_CLOEXEC-and-.patch \
"

SRC_URI[sha256sum] = "7518b49b2eaa1c3091f24671bdcc124fd49fc8f1af51161927afa4329c027848"

DEPENDS_remove = "gdk-pixbuf"
