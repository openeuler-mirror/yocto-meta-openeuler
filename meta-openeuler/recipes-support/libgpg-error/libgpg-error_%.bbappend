# version in openEuler
PV = "1.46"

# apply source package in openEuler
SRC_URI:remove = "${GNUPG_MIRROR}/libgpg-error/libgpg-error-${PV}.tar.bz2 \
           file://pkgconfig.patch \
"

SRC_URI:prepend = "file://libgpg-error-${PV}.tar.gz \
           file://libgpg-error-1.29-multilib.patch \
"

# pkgconfig.patch must be applied, otherwise it makes libgcrypy package
# configure failed. This patch is from open embedded to support version 1.43
SRC_URI += "file://pkgconfig-fix.patch "

# patch directary
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# checksum changed
SRC_URI[sha256sum] = "5b724411231f40cb0454250379a9a659e1dda69c161ba8d69f89c7a39a847b7e"
