
PV="1.19.2"


SRC_URI_remove = "http://www.freedesktop.org/software/${BPN}/${BP}.tar.xz \
"

SRC_URI_prepend = "file://libinput-${PV}.tar.xz \
                   file://0001-evdev-strip-the-device-name-of-format-directives.patch;striplevel=0 \
"

# update license checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=bab4ac7dc1c10bc0fb037dc76c46ef8a"
