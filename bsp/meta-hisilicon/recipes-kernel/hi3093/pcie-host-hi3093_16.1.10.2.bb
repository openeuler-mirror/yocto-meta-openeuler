KO_DIR_NAME = "pcie_host"
KO_NAME = "pcie_hisi02_drv.ko"
PREV_DEPEND += " comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-pcie-hisi02-drv"

require modules-hi3093.inc
