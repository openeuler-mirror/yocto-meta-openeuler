OPENEULER_REPO_NAME = "${XORG_PN}"

SRC_URI:remove = "${XORG_MIRROR}/individual/lib/${XORG_PN}-${PV}.${XORG_EXT}"

SRC_URI:prepend = "file://${XORG_PN}-${PV}.${XORG_EXT} \
           "

XORG_EXT = "tar.gz"
