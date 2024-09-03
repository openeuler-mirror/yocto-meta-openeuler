OPENEULER_REPO_NAMES = "kernel-5.10-tag3093 src-kernel-5.10-tag3093"

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "5.10-tag3093"
OPENEULER_KERNEL_CONFIG = "file://config/hi3093/defconfig"
