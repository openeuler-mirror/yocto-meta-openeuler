# main bb: https://github.com/MarkusVolk/meta-wayland/blob/master/recipes-extended/libdbusmenu/libdbusmenu-gtk_git.bb
inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "libdbusmenu"

PV = "16.0.4"

SRC_URI:prepend = " \
    file://libdbusmenu-4d03141.zip \
"

S = "${WORKDIR}/libdbusmenu-master"

