KO_DIR_NAME = "efuse"
KO_NAME = "efuse_drv/efuse_drv.ko efuse_drv_user_def_uds/efuse_drv_user_def_uds.ko"
PREV_DEPEND += " log-hi3093 djtag-hi3093 comm-hi3093 trng-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-efuse-drv "
RPROVIDES:${PN} += "kernel-module-efuse_drv-user-def-uds "

require modules-hi3093.inc
