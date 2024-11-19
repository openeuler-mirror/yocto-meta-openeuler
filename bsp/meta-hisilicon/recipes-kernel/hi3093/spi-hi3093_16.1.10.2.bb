KO_DIR_NAME = "spi"
KO_NAME = "spi_hi309x_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-spi-hi309x-drv"

require modules-hi3093.inc
