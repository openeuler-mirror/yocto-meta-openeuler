SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

# openeuler-image-mcs is used for mcs development,
# so enable debug-tweaks
OPENEULER_IMAGE_FEATURES = "debug-tweaks"

require openeuler-image-common.inc
require openeuler-image-sdk.inc

# by default, mcs image needs a modified device tree for reserved resources
inherit features_check qemuboot-mcs-dtb
REQUIRED_DISTRO_FEATURES = "mcs"

# basic packages required, e.g., boot, ssh ,debug
# overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-openssh \
packagegroup-mcs \
"

QB_MEM = "-m 2G"
QB_MACHINE:aarch64 = "-machine virt,gic-version=3"
QB_SMP = "-smp 4"
QB_KERNEL_CMDLINE_APPEND = "maxcpus=3"
QB_DTB = "${IMAGE_NAME}.qemuboot.dtb"
QB_DTB_LINK = "${IMAGE_LINK_NAME}.qemuboot.dtb"
