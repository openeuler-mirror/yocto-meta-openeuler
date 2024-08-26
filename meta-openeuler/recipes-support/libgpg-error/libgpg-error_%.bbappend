# version in openEuler
PV = "1.50"

# License update
LIC_FILES_CHKSUM:remove = "file://src/gpg-error.h.in;beginline=2;endline=18;md5=d82591bc81561f617da71e00ff4a9d79"
LIC_FILES_CHKSUM:append = " file://src/gpg-error.h.in;beginline=2;endline=18;md5=badc79a9308e1cbd2657b2441c7cf017"

# patch directory
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# apply source package in openEuler
SRC_URI:remove = "file://pkgconfig.patch \
"

# pkgconfig.patch must be applied, otherwise it makes libgcrypy package
# configure failed. This patch is from open embedded to support version 1.43
SRC_URI += "file://pkgconfig-fix.patch"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
        file://libgpg-error-1.48-multilib.patch \
"
