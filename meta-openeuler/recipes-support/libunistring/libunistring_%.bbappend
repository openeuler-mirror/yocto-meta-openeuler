# main bbfile: yocto-poky/meta/recipes-support/libunistring/libunistring_1.0.bb

PV = "1.1"

# Fix LIC_FILES_CHKSUM for 1.1 vs base recipe 1.2
LIC_FILES_CHKSUM:remove = "file://doc/libunistring.texi;md5=36b7d20daef7fbcc032333ae2429aa94"
LIC_FILES_CHKSUM:append = " file://doc/libunistring.texi;md5=266e4297d7c18f197be3d9622ba99685"

# Remove remote URL (sha256 in base recipe is for a different version)
SRC_URI:remove = "${GNU_MIRROR}/libunistring/libunistring-${PV}.tar.gz"

SRC_URI:prepend = "file://${BP}.tar.xz \
"

SRC_URI[sha256sum] = "827c1eb9cb6e7c738b171745dac0888aa58c5924df2e59239318383de0729b98"

ASSUME_PROVIDE_PKGS = "libunistring"
