OPENEULER_REPO_NAME = "gstreamer1-plugins-base"

PV = "1.20.3"

LIC_FILES_CHKSUM = "file://COPYING;md5=69333daa044cb77e486cc36129f7a770"

# remove outdated patch
SRC_URI_remove = "file://0004-glimagesink-Downrank-to-marginal.patch \
"

SRC_URI += "file://0001-missing-plugins-Remove-the-mpegaudioversion-field.patch \
"

SRC_URI[sha256sum] = "7e30b3dd81a70380ff7554f998471d6996ff76bbe6fc5447096f851e24473c9f"

# keep same as new bbfile below
PACKAGES_DYNAMIC_remove = "^libgst.*"

PACKAGECONFIG[graphene] = "-Dgl-graphene=enabled,-Dgl-graphene=disabled,graphene"
# This enables Qt5 QML examples in -base. The Qt5 GStreamer
# qmlglsink and qmlglsrc plugins still exist in -good.
PACKAGECONFIG[qt5] = "-Dqt5=enabled,-Dqt5=disabled,qtbase qtdeclarative qtbase-native"
PACKAGECONFIG[viv-fb] = ",,virtual/libgles2 virtual/libg2d"

OPENGL_WINSYS_append = "${@bb.utils.contains('PACKAGECONFIG', 'viv-fb', ' viv-fb', '', d)}"

EXTRA_OEMESON_remove = "-Dgl-graphene=disabled \
"
