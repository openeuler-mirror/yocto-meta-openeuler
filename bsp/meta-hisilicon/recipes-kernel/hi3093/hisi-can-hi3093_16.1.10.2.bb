KO_DIR_NAME = "hisi_can"
KO_NAME = "hi_can.ko"
PREV_DEPEND += " ksecurec log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-hi-can"
RPROVIDES:${PN} += "kernel-module-can-dev-${KERNEL_VERSION} "

require modules-hi3093.inc
