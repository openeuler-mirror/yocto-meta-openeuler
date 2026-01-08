DESCRIPTION = "use yocto to re-compile peripherals driver for hieulerpi1, just for kernel 6.6"
SECTION = "peripherals driver"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d229da563da18fe5d58cd95a6467d584"

OPENEULER_LOCAL_NAME = "HiEuler-driver-kernel6"

SRC_URI = " \
        file://HiEuler-driver-kernel6 \
"

S = "${WORKDIR}/HiEuler-driver-kernel6"

inherit module

do_compile() {
    export CROSS_COMPILE=aarch64-openeuler-linux-
    export KERNELDIR=${STAGING_KERNEL_BUILDDIR}

    cd ${S}/i2c_soft
    oe_runmake

    cd ${S}/gpio
    oe_runmake

    cd ${S}/oled
    oe_runmake

    cd ${S}/WS73
    sed -i 's/WSCFG_KERNEL_DIR := $(KERNELDIR)/WSCFG_KERNEL_DIR := $(KERNEL_SRC)/' Makefile.param
    sed -i 's/WSCFG_KERNEL_DIR := $(realpath $(SDK_DIR)\/\.\.\/\.\.\/SS928V100_SDK_V2\.0\.2\.2\/open_source\/linux\/linux-4\.19\.y)/WSCFG_KERNEL_DIR := $(KERNEL_SRC)/' Makefile.param
    oe_runmake
    cd ${S}/WS73/application/sample/sle/sle_uuid/sle_uuid_server
    sed -i 's/aarch64-mix210-linux-/aarch64-openeuler-linux-/g' Makefile
    oe_runmake
    cd ${S}/WS73/application/sample/sle/sle_uuid/sle_uuid_client
    sed -i 's/aarch64-mix210-linux-/aarch64-openeuler-linux-/g' Makefile
    oe_runmake

    cd ${S}/hi_adc
    oe_runmake driver
    oe_runmake application

    cd ${S}/Tsensor
    oe_runmake driver
    oe_runmake application

    cd -
}

do_install () {
    install -d ${D}/opt/sample/mipi_rx
    install -d ${D}/opt/sample/mipi_rx/imx347
    install -d ${D}/opt/sample/mipi_rx/sc450ai
    install -m 644 ${S}/i2c_soft/i2c_soft_driver.ko ${D}/opt/sample/mipi_rx
    #install -m 755 ${S}/scripts_and_configs/mipi_rx/imx347/sns23_reset_4x2lane.sh ${D}/opt/sample/mipi_rx/imx347
    install -m 755 ${S}/scripts_and_configs/mipi_rx/sc450ai/sns23_reset_4x2lane.sh ${D}/opt/sample/mipi_rx/sc450ai

    install -d ${D}/opt/sample/gpio
    install -m 644 ${S}/gpio/gpio_driver.ko ${D}/opt/sample/gpio
    install -m 755 ${S}/scripts_and_configs/gpio/gpio_ctrl.sh ${S}/scripts_and_configs/gpio/gpio_driver_ctrl.sh ${D}/opt/sample/gpio

    install -d ${D}/opt/sample/oled
    install -m 644 ${S}/oled/i2c_oled_driver.ko ${D}/opt/sample/oled

    install -d ${D}/opt/sample/ws73
    install -d ${D}/etc
    install -d ${D}/etc/ws73
    install -d ${D}/etc/wireless
    install -m 644 ${S}/WS73/output/bin/ws73_cfg.ini ${D}/etc
    install -m 755 ${S}/scripts_and_configs/ws73/wifi_sta.sh ${S}/scripts_and_configs/ws73/wifi_ap.sh ${D}/opt/sample/ws73
    install -m 755 ${S}/scripts_and_configs/ws73/sle_server.sh ${S}/scripts_and_configs/ws73/sle_client.sh ${D}/opt/sample/ws73
    install -m 755 ${S}/WS73/application/sample/sle/sle_uuid/sle_uuid_server/sle_server_sample ${D}/opt/sample/ws73
    install -m 755 ${S}/WS73/application/sample/sle/sle_uuid/sle_uuid_client/sle_client_sample ${D}/opt/sample/ws73
    find ${S}/WS73/output/bin -type f -name "*.ko" -exec install -m 644 {} ${D}/opt/sample/ws73 \;
    find ${S}/WS73/firmware/us -type f -name "*.bin" -exec install -m 644 {} ${D}/etc/ws73 \;
    find ${S}/scripts_and_configs/ws73/wireless -type f \
        | xargs -I {} install -m 0644 {} ${D}/etc/wireless

    install -d ${D}/opt/sample/adc
    install -m 644 ${S}/hi_adc/hi_adc.ko ${D}/opt/sample/adc
    install -m 755 ${S}/hi_adc/hi_adc_driver_sample/hi_adc_driver_sample ${D}/opt/sample/adc

    install -d ${D}/opt/sample/tsensor
    install -m 644 ${S}/Tsensor/hi_tsensor.ko ${D}/opt/sample/tsensor
    install -m 755 ${S}/Tsensor/hi_tsensor_driver_sample/hi_tsensor_driver_sample ${D}/opt/sample/tsensor

    install -d ${D}/opt/sample/mipi_tx/source_file
    install -m 755 ${S}/scripts_and_configs/mipi_tx/init_mipitx.sh ${D}/opt/sample/mipi_tx
    install -m 644 ${S}/scripts_and_configs/mipi_tx/source_file/3840x2160_8bit.h265 ${D}/opt/sample/mipi_tx/source_file

    install -d ${D}/opt/sample/storage
    install -m 755 ${S}/scripts_and_configs/storage/test_storage.sh ${D}/opt/sample/storage
}

FILES:${PN} = " /opt/sample /etc/wireless /etc/ws73 /etc/ws73_cfg.ini "

INHIBIT_PACKAGE_STRIP = "1"