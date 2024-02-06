KO_DIR_NAME = "spi"
KO_NAME = "spi_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-spi-drv"

require modules-hi3093.inc
