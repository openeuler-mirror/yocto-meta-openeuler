# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it shoud not include by live image

require ${@bb.utils.contains("DISTRO_FEATURES", "mpu_solution", "pack-hi3093.inc", "recipes-core/images/qemu.inc", d)}

DEPENDS:append = "${@bb.utils.contains("DISTRO_FEATURES", "mpu_solution", " signtools-hi3093 u-boot-emmc ", "", d)}"

# note, these  modules form 3093 bsp not release now:
#   * kernel-module-sol-drv 
#   * kernel-module-ddrc-drv 
#   * kernel-module-virtual-usb-device 
#   * kernel-module-kcs-drv 
#   * kernel-module-p80-drv 
#   * kernel-module-cdev-veth-drv 
#   * kernel-module-physmap-1711 
#   * kernel-module-edma-drv 
#   * kernel-module-ipmb-drv 
#   * kernel-module-sys-info-drv 
#   * kernel-module-mctp-drv 
#   * kernel-module-vce-drv 
#   * kernel-module-efuse-drv 
#   * kernel-module-efuse_drv-user-def-uds 
#   * kernel-module-hi-can 
#   * kernel-module-wdi-drv 
#   * kernel-module-bt-drv 
#   * kernel-module-djtag-drv 
IMAGE_INSTALL += " \
${@bb.utils.contains("DISTRO_FEATURES", "mpu_solution", " \
        packagegroup-bsp-deps \
        imagetools-hi3093 \
        bootfile \
        kernel-module-dboot-drv \
        kernel-module-gpio-drv \
        kernel-module-mmc-block \
        kernel-module-mmc-core \
        kernel-module-emmc-drv \
        kernel-module-sdio-drv \
        kernel-module-bmcrtc-drv \
        kernel-module-hw-lock-drv \
        kernel-module-log-drv \
        kernel-module-uart-drv \
        kernel-module-hitimer-drv \
        kernel-module-peci-drv \
        kernel-module-watchdog-drv \
        kernel-module-ksecurec \
        kernel-module-msg-scm3-drv \
        kernel-module-localbus-drv \
        kernel-module-spi-drv \
        kernel-module-uartconnect-drv \
        kernel-module-trng-drv \
        kernel-module-pci-fix-drv \
        kernel-module-adc-drv \
        kernel-module-pcie-hisi02-drv \
        kernel-module-sfc0-drv \
        kernel-module-sfc1-drv \
        kernel-module-udc-core \
        kernel-module-mdio-drv \
        kernel-module-i2c-drv \
        kernel-module-comm-drv \
        kernel-module-gmac-drv \
        kernel-module-pwm-drv \
        kernel-module-devmem-drv \ 
        kernel-module-configfs \
        kernel-module-usb-drv \
        kernel-module-libcomposite \
        kernel-module-dwc3 \
        kernel-module-usb-common \
", "", d)}"
