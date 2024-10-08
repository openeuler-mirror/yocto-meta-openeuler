# main bb: https://github.com/MarkusVolk/meta-wayland/blob/master/recipes-extended/libdbusmenu/libdbusmenu-gtk_git.bb
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "16.0.4"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/libdbusmenu/libdbusmenu-4d03141.zip \
"

S = "${WORKDIR}/libdbusmenu-master"

