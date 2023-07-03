# main bbfile: yocto-poky/meta/recipes-kernel/kern-tools/kern-tools-native_git.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# avoid parse filespath error after adding FILESEXTRAPATHS
PV = "0.2"

SRC_URI = "file://yocto-kernel-tools.tar.gz"

SRC_URI[sha256sum] = "740f0b7479264fa47b03f2b8094139785a64682ac7218698d0774c47c4d1d4ea"
