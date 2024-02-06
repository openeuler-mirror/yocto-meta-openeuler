KO_DIR_NAME = "watchdog"
KO_NAME = "watchdog_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 timer-hi3093 "
RPROVIDES:${PN} += "kernel-module-watchdog-drv"

require modules-hi3093.inc
