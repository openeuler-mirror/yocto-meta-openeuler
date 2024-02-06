KO_DIR_NAME = "i2c"
KO_NAME = "i2c_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-i2c-drv"

require modules-hi3093.inc
