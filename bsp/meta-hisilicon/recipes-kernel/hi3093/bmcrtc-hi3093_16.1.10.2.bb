KO_DIR_NAME = "bmcrtc"
KO_NAME = "bmcrtc_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-bmcrtc-drv"

require modules-hi3093.inc
