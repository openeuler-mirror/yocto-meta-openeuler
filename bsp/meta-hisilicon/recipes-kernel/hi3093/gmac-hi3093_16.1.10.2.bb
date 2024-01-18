KO_DIR_NAME = "gmac"
KO_NAME = "gmac_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 mdio-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-gmac-drv"

require modules-hi3093.inc
