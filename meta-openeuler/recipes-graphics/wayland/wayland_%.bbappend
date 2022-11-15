PV = "1.20.0"

# 0001-build-Fix-strndup-detection-on-MinGW.patch cannot be applied
SRC_URI_remove = "https://wayland.freedesktop.org/releases/${BPN}-${PV}.tar.xz \
                  file://0001-build-Fix-strndup-detection-on-MinGW.patch \
"
SRC_URI_prepend = "file://wayland-${PV}.tar.xz \
                   file://backport-CVE-2021-3782.patch \
"
