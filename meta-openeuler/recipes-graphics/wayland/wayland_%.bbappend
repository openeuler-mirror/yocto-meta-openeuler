
PV = "1.20.0"

# modify 0002-meson.build-find-the-native-wayland-scanner-directly.patch
FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

# PREFERRED_VERSION_wayland = "1.20.0"

# 0002-meson.build-find-the-native-wayland-scanner-directly.patch is a bug
# in 1.19.3 but still not fixed in 1.20.0
SRC_URI_remove = "https://wayland.freedesktop.org/releases/${BPN}-${PV}.tar.xz \
file://CVE-2021-3782.patch \
"
SRC_URI_prepend = "file://wayland-${PV}.tar.xz \
file://backport-CVE-2021-3782.patch \
file://0003-meson.build-find-the-native-wayland-scanner-directly.patch \
"