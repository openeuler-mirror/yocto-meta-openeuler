KO_DIR_NAME = "adc"
KO_NAME = "adc_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-adc-drv"

require modules-hi3093.inc
