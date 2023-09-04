OPENEULER_SRC_URI_REMOVE = "http git"

PV = "1.22.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:remove = "file://0002-Do-not-hardcode-the-path-to-wayland-scanner.patch \
           file://CVE-2021-3782.patch \
           "

SRC_URI:prepend = "file://wayland-${PV}.tar.xz \
           "

# this is a description:

# 0002-meson.build-find-the-native-wayland-scanner-directly.patch
# fix wayland error: pkgconfig can't find wayland-scanner

# in version 1.21.0: 0002-Do-not-hardcode-the-path-to-wayland-scanner.patch was removed
# as we use pkg-config in hosttools instead of pkgconfig-native,
# this result in error: wayland-scanner can not being found
# So we add it back temporarily, and rename it by adding '-bak'
# we can remove these patches until we solve the problem with pkg-config
SRC_URI:append = " \
           file://0002-meson.build-find-the-native-wayland-scanner-directly.patch \
           file://0002-Do-not-hardcode-the-path-to-wayland-scanner-bak.patch \
           "
