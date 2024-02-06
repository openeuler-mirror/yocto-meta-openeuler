KO_DIR_NAME = "usb_core"
KO_NAME = "udc-core.ko"
PREV_DEPEND += "log-hi3093"

require modules-hi3093.inc

do_configure:prepend() {
    sed -i "s#^USB_OPEN_SOURCE_DIR=.*#USB_OPEN_SOURCE_DIR=${STAGING_KERNEL_DIR}/drivers/usb#g" ${S}/Makefile
}

RPROVIDES:${PN} += "kernel-module-udc-core"
