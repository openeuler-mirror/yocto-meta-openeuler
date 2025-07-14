# tspi-3566 settings
SRC_URI:tspi-3566 = " \
    file://rockchip-kernel-tspi-3566 \
    file://patches/0001-fix-wl_android-module-compile-about-rev_info_delim-i.patch \
"
OPENEULER_LOCAL_NAME:tspi-3566 = "rockchip-kernel-tspi-3566"
OPENEULER_REPO_NAMES:tspi-3566 = "rockchip-kernel-tspi-3566"
S:tspi-3566 = "${WORKDIR}/rockchip-kernel-tspi-3566"
PV:tspi-3566 = "5.10.209"
DEPENDS:tspi-3566:append = " lz4-native "
