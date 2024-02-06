KO_DIR_NAME = "pwm"
KO_NAME = "pwm_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-pwm-drv"

require modules-hi3093.inc
