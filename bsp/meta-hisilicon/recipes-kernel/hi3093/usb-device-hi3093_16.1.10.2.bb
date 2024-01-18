KO_DIR_NAME = "usb_device"
KO_NAME = "virtual_usb_device.ko"
PREV_DEPEND += " log-hi3093 usb-core-hi3093 usb-hi3093 comm-hi3093 usb-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-virtual-usb-device"

require modules-hi3093.inc
