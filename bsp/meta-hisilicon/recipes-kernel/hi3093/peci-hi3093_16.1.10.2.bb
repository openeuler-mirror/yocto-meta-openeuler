KO_DIR_NAME = "peci"
KO_NAME = "peci_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-peci-drv"

require modules-hi3093.inc
