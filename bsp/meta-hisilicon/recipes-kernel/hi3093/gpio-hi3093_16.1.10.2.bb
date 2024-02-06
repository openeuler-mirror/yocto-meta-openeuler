KO_DIR_NAME = "gpio"
KO_NAME = "gpio_drv.ko"
PREV_DEPEND += " comm-hi3093 log-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-gpio-drv"

require modules-hi3093.inc
