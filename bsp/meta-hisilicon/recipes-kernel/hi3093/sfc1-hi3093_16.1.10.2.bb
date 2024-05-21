KO_DIR_NAME = "sfccom"
KO_NAME = "sfc1/sfc1_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec hw-lock-hi3093 "
RPROVIDES:${PN} += "kernel-module-sfc1-drv "

require modules-hi3093.inc

# the Makefile is not standardized, the sfc1 module, which belongs to the 
# sfccomm component, should be compiled first before sfc0, so we make split here.
do_configure:append() {
    sed -i '/sfc0/d' ${S}/Makefile
}

