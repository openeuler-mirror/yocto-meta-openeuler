SUMMARY = "SFWBar (S* Floating Window Bar) is a flexible taskbar application for wayland compositors"
DESCRIPTION = "SFWBar (S* Floating Window Bar) is a flexible taskbar application for wayland compositors, designed with a stacking layout in mind. Originally developed for Sway, SFWBar will work with any wayland compositor supporting layer shell protocol, the taskbar and window switcher functionality shall work with any compositor supportinig foreign toplevel protocol, but the pager, and window placement functionality require sway (or at least i3 IPC support)."
HOMEPAGE = "https://github.com/Alexays/Waybar"
BUGTRACKER = "https://github.com/Alexays/Waybar/issues"
SECTION = "graphics"
LICENSE = "GPLv3 & MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

REQUIRED_DISTRO_FEATURES = "wayland"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "1.0.beta15"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/v1.0_beta15.tar.gz \
"

S = "${WORKDIR}/sfwbar-1.0_beta15"

DEPENDS += " \
	glib-2.0-native \
	gtkmm3 \
	json-c \
    gtk-layer-shell \
	libxkbcommon \
	gtk+3 \
	gobject-introspection \
	wayland \
	wayland-native \
	wayland-protocols \
"

RRECOMMENDS:${PN} += "font-awesome-otf"

inherit meson pkgconfig features_check

PACKAGECONFIG[alsa] = "-Dalsa=enabled,-Dalsa=disabled,alsa-lib"
PACKAGECONFIG[bluez] = "-Dbluez=enabled,-Dbluez=disabled,bluez5"
PACKAGECONFIG[iwd] = "-Diwd=enabled,-Diwd=disabled"
PACKAGECONFIG[nm] = "-Dnm=enabled,-Dnm=disabled"
PACKAGECONFIG[bsdctl] = "-Dbsdctl=enabled,-Dbsdctl=disabled"
PACKAGECONFIG[idleinhibit] = "-Didleinhibit=enabled,-Didleinhibit=disabled"
PACKAGECONFIG[network] = "-Dnetwork=enabled,-Dnetwork=disabled"
PACKAGECONFIG[mpd] = "-Dmpd=enabled,-Dmpd=disabled,libmpdclient"
PACKAGECONFIG[pulse] = "-Dpulse=enabled,-Dpulse=disabled,pulseaudio"
PACKAGECONFIG[xkb] = "-Dxkb=enabled,-Dxkb=disabled,libxkbcommon"
PACKAGECONFIG[build-docs] = "-Dbuild-docs=enabled,-Dbuild-docs=disabled"

PACKAGECONFIG ?= " \
    alsa \
    bluez \
    iwd \
    nm \
    idleinhibit \
    network \
    ${@bb.utils.filter('DISTRO_FEATURES', 'pulseaudio', d)} \
    xkb \ 
"
FILES:${PN} += " ${datadir} "

