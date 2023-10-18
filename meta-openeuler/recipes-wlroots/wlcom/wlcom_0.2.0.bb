SUMMARY = "kylin-wayland-compositor"
HOMEPAGE = "https://gitee.com/openkylin/kylin-wayland-compositor"
BUGTRACKER = "https://gitee.com/openkylin/kylin-wayland-compositor/issues"
SECTION = "graphics"
LICENSE = "LGPL"

LIC_FILES_CHKSUM = "file://${S}/LICENSES/LGPL-2.1-or-later.txt;md5=41890f71f740302b785c27661123bff5"

REQUIRED_DISTRO_FEATURES = "wayland"

OPENEULER_LOCAL_NAME = "kylin-wayland-compositor"

DEPENDS += " \
    pixman \
    cglm \
    virtual/libgles2 \
    librsvg \
    pango \
    cairo \
    json-c \
    wlroots \
	libevdev \
	libinput \
	libxkbcommon \
	libxml2 \
	mesa \
	wayland \
	wayland-native \
	wayland-protocols \
"
PV = "0.2.0"

SRC_URI = " \
        file://kylin-wayland-compositor \
        file://0001-fix-deps.patch \
        file://0001-wlr-fit-committed-and-buffer-remove-from-wlr.patch \
"

S = "${WORKDIR}/kylin-wayland-compositor"

inherit meson pkgconfig features_check

EXTRA_OEMESON += "--buildtype release"

FILES:${PN} += "${datadir} ${libdir}"

BBCLASSEXTEND = ""

