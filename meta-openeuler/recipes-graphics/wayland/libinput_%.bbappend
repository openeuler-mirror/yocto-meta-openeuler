
PV="1.22.1"

# update license checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=bab4ac7dc1c10bc0fb037dc76c46ef8a"

SRC_URI_remove = "http://www.freedesktop.org/software/${BPN}/${BP}.tar.xz \
"

SRC_URI_prepend = "file://libinput-${PV}.tar.gz \
"

SRC_URI[sha256sum] = "45d9e03c16c3c343b7537aa7f744ae9339b1a0dae446ecbe6f5ed9d49be11e87"
