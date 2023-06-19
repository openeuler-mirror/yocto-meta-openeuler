OPENEULER_REPO_NAME = "xorg-x11-server-utils"

PV = "1.5.0"

SRC_URI:remove = "${XORG_MIRROR}/individual/app/${BPN}-${PV}.tar.xz"

SRC_URI:prepend = "file://${BPN}-${PV}.tar.bz2 \
           "
SRC_URI[sha256sum] = "c1cfd4e1d4d708c031d60801e527abc9b6d34b85f2ffa2cadd21f75ff38151cd"
