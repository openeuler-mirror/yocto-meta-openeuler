
PV = "0.17"

inherit meson

SRC_URI:prepend = "file://${BP}.tar.gz \
                file://0000-libpciaccess-rom-size.patch \
"

SRC_URI[sha256sum] = "4af43444b38adb5545d0ed1c2ce46d9608cc47b31c2387fc5181656765a6fa76"
LIC_FILES_CHKSUM = "file://COPYING;md5=277aada5222b9a22fbf3471ff3687068"

PACKAGECONFIG[xmlto] = ""
