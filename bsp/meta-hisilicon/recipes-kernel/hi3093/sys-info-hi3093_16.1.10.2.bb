KO_DIR_NAME = "sys_info"
KO_NAME = "sys_info_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-sys-info-drv"

require modules-hi3093.inc
