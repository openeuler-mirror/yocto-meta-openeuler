KO_DIR_NAME = "sfccom"
KO_NAME = "sfc0/sfc0_drv.ko sfc1/sfc1_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec hw-lock-hi3093 "
RPROVIDES:${PN} += "kernel-module-sfc0-drv "
RPROVIDES:${PN} += "kernel-module-sfc1-drv "
RPROVIDES:${PN} += "kernel-module-mtd-${KERNEL_VERSION} "

require modules-hi3093.inc
