KO_DIR_NAME = "sfccom"
KO_NAME = "sfc0/sfc0_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec hw-lock-hi3093 sfc1-hi3093 "
RPROVIDES:${PN} += "kernel-module-sfc0-drv "
RPROVIDES:${PN} += "kernel-module-mtd-${KERNEL_VERSION} "

require modules-hi3093.inc

# the Makefile is not standardized, the sfc1 module, which belongs to the 
# sfccomm component, should be compiled first before sfc0, so we make split here.
do_configure:append() {
    sed -i '/sfc1/d' ${S}/Makefile
}

