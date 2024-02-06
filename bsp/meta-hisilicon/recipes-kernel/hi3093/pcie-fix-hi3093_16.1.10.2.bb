KO_DIR_NAME = "pcie_fix"
KO_NAME = "pci_fix_drv.ko"
PREV_DEPEND += " log-hi3093 ksecurec comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-pci-fix-drv"

require modules-hi3093.inc
