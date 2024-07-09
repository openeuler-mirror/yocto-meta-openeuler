# bb ref: meta-wayland/recipes-wlroots/labwc/labwc-tweaks_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

# https://github.com/labwc/labwc-tweaks need QT6 after 2024.4
# the GTK version changed to https://github.com/labwc/labwc-tweaks-gtk

SUMMARY = "This is a [WIP] configuration gui app for labwc without any real plan or Acceptance Criteria"
HOMEPAGE = "https://github.com/labwc/labwc-tweaks"
SECTION = "graphics"
LICENSE = "GPL-2.0-only"

LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

REQUIRED_DISTRO_FEATURES = "wayland"

OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR = "labwc"

DEPENDS += " \
	libxml2 \
	glib-2.0 \
	gtk+3 \
    gsettings-desktop-schemas \
"

inherit meson pkgconfig features_check

PV = "485961a"

SRC_URI += " \
    file://${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUBDIR}/labwc-tweaks-gtk-485961a.zip \
"

S = "${WORKDIR}/labwc-tweaks-gtk-master"

FILES:${PN} += "${datadir}"

