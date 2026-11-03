SUMMARY = "A general purpose TCP-IP emulator"
DESCRIPTION = "libslirp is a user-mode networking library used by virtual \
emulators, frameworks and tools"
HOMEPAGE = "https://gitlab.freedesktop.org/slirp/libslirp"
LICENSE = "BSD-3-Clause & MIT"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=bca0186b14e6b05e338e729f106db727"

SRC_URI = "file://libslirp-${PV}.tar.xz"
SRC_URI[sha256sum] = "3470767abf6d269ea9497422302c98d46ace45a70fbe9f88583b154282a2c5c0"

DEPENDS = "glib-2.0"

inherit meson pkgconfig

BBCLASSEXTEND = "native nativesdk"
