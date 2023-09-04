OPENEULER_SRC_URI_REMOVE = "http git"

PV = "1.22.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:remove = "file://0002-Do-not-hardcode-the-path-to-wayland-scanner.patch \
           file://CVE-2021-3782.patch \
"

# 0002-meson.build-find-the-native-wayland-scanner-directly.patch
# fix error: pkgconfig can't find wayland-scanner
SRC_URI:prepend = "file://wayland-${PV}.tar.xz \
           file://0002-meson.build-find-the-native-wayland-scanner-directly.patch \
"
