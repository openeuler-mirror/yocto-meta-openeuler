KO_DIR_NAME = "msg_scm3"
KO_NAME = "msg_scm3_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-msg-scm3-drv"

require modules-hi3093.inc
