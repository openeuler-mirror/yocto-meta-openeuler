# main bb: https://github.com/MarkusVolk/meta-wayland/blob/master/recipes-extended/libdbusmenu/libdbusmenu-gtk_git.bb
#
# consume the release tarball from src-openeuler/libdbusmenu
# (https://atomgit.com/src-openeuler/libdbusmenu) instead of the oee
# archive; bump PV from 16.0.4 (git) to the 16.04.0 release

PV = "16.04.0"

SRC_URI:remove = "git://github.com/AyatanaIndicators/libdbusmenu.git;protocol=https;branch=master"

SRC_URI:prepend = " \
    file://libdbusmenu-${PV}.tar.gz \
    file://0001-libdbusmenu-add-patch-to-modify-build-err.patch;striplevel=2 \
"

SRC_URI[sha256sum] = "b9cc4a2acd74509435892823607d966d424bd9ad5d0b00938f27240a1bfa878a"

S = "${WORKDIR}/libdbusmenu-${PV}"
