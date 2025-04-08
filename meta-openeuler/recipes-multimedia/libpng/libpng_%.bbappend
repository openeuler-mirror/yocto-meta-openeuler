LIC_FILES_CHKSUM = "file://LICENSE;md5=0fdbfbe10fc294a6fca24dc76134222a"

PV = "1.6.43"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://libpng-multilib.patch \
"

SRC_URI[sha256sum] = "6a5ca0652392a2d7c9db2ae5b40210843c0bbc081cbd410825ab00cc59f14a6c"

ASSUME_PROVIDE_PKGS = "libpng"
