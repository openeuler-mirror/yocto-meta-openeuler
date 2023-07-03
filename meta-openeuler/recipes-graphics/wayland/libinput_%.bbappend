# the main bb file: yocto-poky/meta/recipes-graphics/wayland/libinput_1.19.4.bb

PV="1.22.1"

# update license checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=bab4ac7dc1c10bc0fb037dc76c46ef8a"

SRC_URI:remove = "http://www.freedesktop.org/software/${BPN}/${BP}.tar.xz \
"

SRC_URI:prepend = "file://libinput-${PV}.tar.gz \
"

SRC_URI[sha256sum] = "45d9e03c16c3c343b7537aa7f744ae9339b1a0dae446ecbe6f5ed9d49be11e87"
