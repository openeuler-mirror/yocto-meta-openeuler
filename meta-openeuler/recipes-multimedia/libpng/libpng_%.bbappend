LIC_FILES_CHKSUM = "file://LICENSE;md5=9dc350edbbbee660c7d9af79487168f2"

PV = "1.6.59"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI:prepend = "file://${BP}.tar.xz \
           file://libpng-multilib.patch \
"

SRC_URI[sha256sum] = "6a5ca0652392a2d7c9db2ae5b40210843c0bbc081cbd410825ab00cc59f14a6c"

ASSUME_PROVIDE_PKGS = "libpng"
