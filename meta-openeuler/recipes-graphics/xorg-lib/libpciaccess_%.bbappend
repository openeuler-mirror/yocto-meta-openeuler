
PV = "0.18.1"

inherit meson

SRC_URI:prepend = "file://${BP}.tar.xz \
                file://0000-libpciaccess-rom-size.patch \
"

SRC_URI[sha256sum] = "4af43444b38adb5545d0ed1c2ce46d9608cc47b31c2387fc5181656765a6fa76"
LIC_FILES_CHKSUM = "file://COPYING;md5=54c978968e565218eea36cf03ef24352"

PACKAGECONFIG[xmlto] = ""
