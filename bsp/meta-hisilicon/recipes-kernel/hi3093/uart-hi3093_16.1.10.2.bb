KO_DIR_NAME = "uart"
KO_NAME = "uart_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-uart-drv "
RPROVIDES:${PN} += "kernel-module-uart-core-${KERNEL_VERSION} "

require modules-hi3093.inc
