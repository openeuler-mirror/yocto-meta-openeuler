KO_DIR_NAME = "sdio"
KO_NAME = "mmc_block.ko emmc/emmc_drv.ko mmc_core.ko sdio/sdio_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec hw-lock-hi3093 "

require modules-hi3093.inc

do_configure:prepend() {
    sed -i "s#^MMC_OPEN_SOURCE_DIR=.*#MMC_OPEN_SOURCE_DIR=${STAGING_KERNEL_DIR}/drivers/mmc#g" ${S}/Makefile
}

RPROVIDES:${PN} += "kernel-module-mmc-block "
RPROVIDES:${PN} += "kernel-module-mmc-core "
RPROVIDES:${PN} += "kernel-module-emmc-drv "
RPROVIDES:${PN} += "kernel-module-sdio-drv "
