DESCRIPTION = "WS73 USB WiFi driver compiled from HiEuler-driver-kernel6 source"
SECTION = "base"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d229da563da18fe5d58cd95a6467d584"

OPENEULER_LOCAL_NAME = "HiEuler-driver-kernel6"

SRC_URI = "file://HiEuler-driver-kernel6"

S = "${WORKDIR}/HiEuler-driver-kernel6"

inherit module

do_compile() {
    cd ${S}/WS73

    sed -i 's/^_PRE_PLAT_HCC_SDIO=y/# _PRE_PLAT_HCC_SDIO is not set/' build/config/ws73_default.config
    sed -i 's/^CONFIG_HCC_SDIO_SUPPORT_SCATTER=y/# CONFIG_HCC_SDIO_SUPPORT_SCATTER is not set/' build/config/ws73_default.config
    sed -i 's/^CONFIG_SDIO_RESCAN=y/# CONFIG_SDIO_RESCAN is not set/' build/config/ws73_default.config

    sed -i 's/^CONFIG_INI_HOST_GPIO=40/CONFIG_INI_HOST_GPIO=-1/' build/config/ws73_default.config
    sed -i 's/^CONFIG_INI_WAKE_UP_GPIO_IDX=70/CONFIG_INI_WAKE_UP_GPIO_IDX=-1/' build/config/ws73_default.config

    sed -i 's/WSCFG_KERNEL_DIR := $(KERNELDIR)/WSCFG_KERNEL_DIR := $(KERNEL_SRC)/' Makefile.param
    sed -i 's/WSCFG_KERNEL_DIR := $(realpath $(SDK_DIR)\/\.\.\/\.\.\/SS928V100_SDK_V2\.0\.2\.2\/open_source\/linux\/linux-4\.19\.y)/WSCFG_KERNEL_DIR := $(KERNEL_SRC)/' Makefile.param

    rm -f .config

    oe_runmake platform wifi
}

do_install() {
    install -d ${D}/ko/wifi
    install -d ${D}${sysconfdir}/ws73
    install -d ${D}${sysconfdir}

    install -m 644 ${S}/WS73/output/bin/plat_soc.ko ${D}/ko/wifi/
    install -m 644 ${S}/WS73/output/bin/wifi_soc.ko ${D}/ko/wifi/
    install -m 644 ${S}/WS73/output/bin/ws73_cfg.ini ${D}${sysconfdir}/

    install -m 644 ${S}/WS73/firmware/us/ws73.bin ${D}${sysconfdir}/ws73/
    install -m 644 ${S}/WS73/firmware/us/wifi_cali.bin ${D}${sysconfdir}/ws73/
    install -m 644 ${S}/WS73/firmware/us/btc_cali.bin ${D}${sysconfdir}/ws73/
    install -m 644 ${S}/WS73/firmware/us/wow.bin ${D}${sysconfdir}/ws73/
}

FILES:${PN} = "/ko/wifi ${sysconfdir}/ws73 ${sysconfdir}/ws73_cfg.ini"

INHIBIT_PACKAGE_STRIP = "1"
