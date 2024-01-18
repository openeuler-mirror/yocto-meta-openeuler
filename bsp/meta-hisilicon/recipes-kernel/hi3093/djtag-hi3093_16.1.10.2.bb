KO_DIR_NAME = "djtag"
KO_NAME = "djtag_drv.ko"
PREV_DEPEND += " comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-djtag-drv"

require modules-hi3093.inc
