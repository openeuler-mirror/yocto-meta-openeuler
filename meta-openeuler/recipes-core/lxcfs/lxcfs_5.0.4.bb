SUMMARY = "LXCFS is a userspace filesystem created to avoid kernel limitations"
LICENSE = "LGPL-2.1-or-later"

REQUIRED_DISTRO_FEATURES ?= "systemd"
inherit meson pkgconfig systemd features_check

SRC_URI = " \
    https://linuxcontainers.org/downloads/lxcfs/lxcfs-${PV}.tar.gz \
    file://0001-bindings-fix-build-with-newer-linux-libc-headers.patch \
    file://0001-meson.build-force-pid-open-send_signal-detection.patch \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=29ae50a788f33f663405488bc61eecb1"
SRC_URI[md5sum] = "00a6632e094d0a2f2308c8365ac91912"
SRC_URI[sha256sum] = "c2b361edc881d5ca8fa2cd3260a4999b8f87afce8d937be2160e5cf0b482c52f"

DEPENDS += "fuse python3-jinja2-native help2man-native systemd"
RDEPENDS:${PN} += "fuse"

FILES:${PN} += "${datadir}/lxc/config/common.conf.d/*"

# help2man doesn't work, so we disable docs
EXTRA_OEMESON += "-Dinit-script=${VIRTUAL-RUNTIME_init_manager} -Ddocs=false"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "lxcfs.service"
