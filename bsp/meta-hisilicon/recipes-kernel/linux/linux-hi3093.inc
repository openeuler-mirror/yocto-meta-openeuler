OPENEULER_REPO_NAMES = "kernel-5.10-tag3093 src-kernel-5.10-tag3093"

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI = " \
    file://kernel-5.10-tag3093 \
    file://config/hi3093/defconfig \
"

S = "${WORKDIR}/kernel-5.10-tag3093"
