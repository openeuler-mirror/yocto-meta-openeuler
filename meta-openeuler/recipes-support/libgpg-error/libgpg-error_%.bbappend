# version in openEuler
PV = "1.47"

OPENEULER_SRC_URI_REMOVE = "http git"

# License update
LIC_FILES_CHKSUM:remove = "file://src/gpg-error.h.in;beginline=2;endline=18;md5=d82591bc81561f617da71e00ff4a9d79"
LIC_FILES_CHKSUM:append = " file://src/gpg-error.h.in;beginline=2;endline=18;md5=20f4cf5d81ea2fad18f6297500018654"

# patch directary
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# apply source package in openEuler
SRC_URI:remove = "file://pkgconfig.patch \
"

# pkgconfig.patch must be applied, otherwise it makes libgcrypy package
# configure failed. This patch is from open embedded to support version 1.43
SRC_URI += "file://pkgconfig-fix.patch"

SRC_URI:prepend = "file://libgpg-error-${PV}.tar.gz \
           file://libgpg-error-1.29-multilib.patch \
"
