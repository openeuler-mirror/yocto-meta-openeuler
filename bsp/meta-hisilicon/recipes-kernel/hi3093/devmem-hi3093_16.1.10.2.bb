KO_DIR_NAME = "devmem"
KO_NAME = "devmem_drv.ko"
PREV_DEPEND += " "
RPROVIDES:${PN} += "kernel-module-devmem-drv"

require modules-hi3093.inc
