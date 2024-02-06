KO_DIR_NAME = "mctp"
KO_NAME = "mctp_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-mctp-drv"

require modules-hi3093.inc
