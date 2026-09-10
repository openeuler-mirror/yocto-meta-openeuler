PV = "1.4.7"

# ref: https://www.x.org/releases/individual/app/xkbcomp-1.4.7.tar.xz
SRC_URI = " \
    file://${BPN}-${PV}.tar.xz \
"

# checksum for the src-openeuler tarball, overriding poky's anonymous
# checksum key which binds to the first URI in SRC_URI
SRC_URI[sha256sum] = "0a288114e5f44e31987042c79aecff1ffad53a8154b8ec971c24a69a80f81f77"
