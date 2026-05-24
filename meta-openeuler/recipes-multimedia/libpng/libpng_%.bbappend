# LIC_FILES_CHKSUM is correctly set in libpng_1.6.40.bb; remove this override
# LIC_FILES_CHKSUM = "file://LICENSE;md5=8f533bc367bfd43f556b6f782234c076"

PV = "1.6.40"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://libpng-multilib.patch \
"

SRC_URI[sha256sum] = "6a5ca0652392a2d7c9db2ae5b40210843c0bbc081cbd410825ab00cc59f14a6c"

ASSUME_PROVIDE_PKGS = "libpng"
