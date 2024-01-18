KO_DIR_NAME = "hw_lock"
KO_NAME = "hw_lock_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-hw-lock-drv"

require modules-hi3093.inc
