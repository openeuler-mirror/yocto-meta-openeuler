# version in openEuler
PV = "1.43"

# apply source package in openEuler
SRC_URI_remove = "${GNUPG_MIRROR}/libgpg-error/libgpg-error-${PV}.tar.bz2 \
file://pkgconfig.patch \
"

SRC_URI_prepend = "file://libgpg-error/libgpg-error-${PV}.tar.gz \
"

# pkgconfig.patch must be applied, otherwise it makes libgcrypy package
# configure failed. This patch is from open embedded to support version 1.43
SRC_URI += "file://pkgconfig-fix.patch "

# patch directary
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# checksum changed
SRC_URI[sha256sum] = "a260706dbab849b85f6eabe418f6dc58e22bddf4b9d7fccb681907e43408d0c9"
