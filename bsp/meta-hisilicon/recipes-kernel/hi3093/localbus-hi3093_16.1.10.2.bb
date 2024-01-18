KO_DIR_NAME = "local_bus"
KO_NAME = "localbus_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-localbus-drv"

require modules-hi3093.inc
