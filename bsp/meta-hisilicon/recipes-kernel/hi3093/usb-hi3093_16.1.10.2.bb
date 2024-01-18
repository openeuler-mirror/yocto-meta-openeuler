KO_DIR_NAME = "usb"
KO_NAME = "configfs.ko usb_drv.ko libcomposite.ko dwc3.ko usb-common.ko"
PREV_DEPEND += " usb-core-hi3093 comm-hi3093 ksecurec "

require modules-hi3093.inc

do_configure:prepend() {
    # fix kernel source link
    sed -i "s#^USB_OPEN_SOURCE_DIR=.*#USB_OPEN_SOURCE_DIR=${STAGING_KERNEL_DIR}/drivers/usb#g" ${S}/Makefile
    sed -i "s#^CONFIGFS_OPEN_SOURCE_DIR=.*#CONFIGFS_OPEN_SOURCE_DIR=${STAGING_KERNEL_DIR}/fs/configfs#g" ${S}/Makefile

    # fix usb_drv.h: No such file or directory 
    sed -i "s#^ccflags-y += -DCONFIG_USB_DWC3_DUAL_ROLE=1.*#ccflags-y += -DCONFIG_USB_DWC3_DUAL_ROLE=1 -I${S} -I${S}/dwc3 #g" ${S}/Makefile
}

RPROVIDES:${PN} += "kernel-module-configfs "
RPROVIDES:${PN} += "kernel-module-usb-drv "
RPROVIDES:${PN} += "kernel-module-libcomposite "
RPROVIDES:${PN} += "kernel-module-dwc3 "
RPROVIDES:${PN} += "kernel-module-usb-common "
