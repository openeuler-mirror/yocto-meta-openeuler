KO_DIR_NAME = "mdio"
KO_NAME = "mdio_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-mdio-drv"

require modules-hi3093.inc
