DESCRIPTION = "use yocto to re-compile peripherals sample for hieulerpi1, just for kernel 6.6"
SECTION = "peripherals sample"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d229da563da18fe5d58cd95a6467d584"

OPENEULER_LOCAL_NAME = "HiEuler-sample-kernel6"

SRC_URI = " \
        file://HiEuler-sample-kernel6 \
"

S = "${WORKDIR}/HiEuler-sample-kernel6"

inherit module

do_compile() {
    export OS_TYPE=openeuler
    export CROSS_COMPILE=aarch64-openeuler-linux-
    cd ${S}
    sed -i 's/CROSS_COMPILE=arm-openeuler-linux-gnueabi-/CROSS_COMPILE=aarch64-openeuler-linux-/g' Makefile.param
    oe_runmake
    cd -
}

do_install () {
    install -d ${D}/opt/sample/oled
    install -m 755 ${S}/i2c_oled/oled ${D}/opt/sample/oled

    install -d ${D}/opt/sample/pwm
    install -m 755 ${S}/pwm/hi_pwm_sample ${D}/opt/sample/pwm

    install -d ${D}/opt/sample/uart
    install -m 755 ${S}/uart/hi_uart_sample ${D}/opt/sample/uart

    install -d ${D}/sbin
    install -m 755 ${S}/mcu_tool/mcu_tool ${D}/sbin
}

FILES:${PN} = " /opt/sample /sbin "

INHIBIT_PACKAGE_STRIP = "1"