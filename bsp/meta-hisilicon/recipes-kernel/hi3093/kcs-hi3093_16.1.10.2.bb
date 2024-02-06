KO_DIR_NAME = "kcs"
KO_NAME = "kcs_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-kcs-drv"

require modules-hi3093.inc
