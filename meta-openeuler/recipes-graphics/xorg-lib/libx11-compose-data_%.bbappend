# main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/libx11-compose-data_1.6.8.bb

OPENEULER_REPO_NAME = "libX11"

# update 0001-Drop-x11-dependencies.patch to libX11-1.7.2
FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

PV = "1.7.2"

SRC_URI_prepend = "file://dont-forward-keycode-0.patch \
                   file://backport-makekeys-handle-the-new-EVDEVK-xorgproto-symbols.patch \
                   "

SRC_URI[md5sum] = "a9a24be62503d5e34df6b28204956a7b"
SRC_URI[sha256sum] = "1cfa35e37aaabbe4792e9bb690468efefbfbf6b147d9c69d6f90d13c3092ea6c"
