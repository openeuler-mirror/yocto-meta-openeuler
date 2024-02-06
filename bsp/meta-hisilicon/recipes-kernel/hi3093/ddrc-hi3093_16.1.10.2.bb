KO_DIR_NAME = "ddrc"
KO_NAME = "ddrc_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-ddrc-drv"

require modules-hi3093.inc
