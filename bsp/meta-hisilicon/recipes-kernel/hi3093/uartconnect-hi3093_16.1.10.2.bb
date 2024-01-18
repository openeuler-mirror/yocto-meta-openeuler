KO_DIR_NAME = "uart_connect"
KO_NAME = "uartconnect_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-uartconnect-drv"

require modules-hi3093.inc
