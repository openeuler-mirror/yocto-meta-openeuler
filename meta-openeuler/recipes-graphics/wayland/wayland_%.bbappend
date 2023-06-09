
PV = "1.20.0"

# modify 0002-meson.build-find-the-native-wayland-scanner-directly.patch
FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

# 0001-build-Fix-strndup-detection-on-MinGW.patch cannot be applied
SRC_URI_remove = "https://wayland.freedesktop.org/releases/${BPN}-${PV}.tar.xz \
                  file://0001-build-Fix-strndup-detection-on-MinGW.patch \
"
SRC_URI_prepend = "file://wayland-${PV}.tar.gz \
                   file://backport-CVE-2021-3782.patch \
"

# fix ERROR: Problem encountered: -Dtests=true requires -Dlibraries=true
EXTRA_OEMESON_remove_class-native = "-Dlibraries=false"
