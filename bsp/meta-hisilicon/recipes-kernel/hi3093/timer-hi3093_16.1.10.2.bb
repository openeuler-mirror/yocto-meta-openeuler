KO_DIR_NAME = "timer"
KO_NAME = "hitimer_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-hitimer-drv"

require modules-hi3093.inc
