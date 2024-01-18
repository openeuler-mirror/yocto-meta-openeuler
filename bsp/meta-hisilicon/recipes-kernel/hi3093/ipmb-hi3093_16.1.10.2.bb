KO_DIR_NAME = "ipmb"
KO_NAME = "ipmb_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-ipmb-drv"

require modules-hi3093.inc
