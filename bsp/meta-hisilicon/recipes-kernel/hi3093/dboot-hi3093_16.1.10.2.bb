KO_DIR_NAME = "dboot"
KO_NAME = "dboot_drv.ko"
PREV_DEPEND += "uart-hi3093"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-dboot-drv"

require modules-hi3093.inc
