KO_DIR_NAME = "virtual_cdev_veth"
KO_NAME = "cdev_veth_drv.ko"
PREV_DEPEND += " edma-hi3093 log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-cdev-veth-drv"

require modules-hi3093.inc
