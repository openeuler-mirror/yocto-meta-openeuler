# main bb: https://github.com/MarkusVolk/meta-wayland/blob/master/recipes-extended/libdbusmenu/libdbusmenu-gtk_git.bb
OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR="libdbusmenu"

PV = "16.0.4"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUBDIR}/libdbusmenu-4d03141.zip \
"

S = "${WORKDIR}/libdbusmenu-master"

