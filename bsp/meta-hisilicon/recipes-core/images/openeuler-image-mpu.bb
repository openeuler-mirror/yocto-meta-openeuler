IMAGE_FSTYPES = "ext4 live cpio.gz"
IMAGE_FSTYPES:remove = "iso"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"

INITRD_IMAGE_LIVE = "initrd-boot"
INITRAMFS_MAXSIZE = "476591"
IMAGE_ROOTFS_SIZE = "387072"

require openeuler-image-common.inc

DEPENDS:append = " signtools-hi3093 u-boot-emmc "

update_cpio_for_ext4() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cd "${IMAGE_ROOTFS}"
    if [ -d ./tools-tmp ];then
        cp -f ./tools-tmp/bin/* ./bin
        cp -f ./tools-tmp/hi3093_init.sh ./
        cp -f ./tools-tmp/hi3093_upgrade.sh ./
        cp -f ./tools-tmp/link_emmc_devs ./
        rm -rf ./tools-tmp
    fi
    cp -fp ./boot/zImage ${OUTPUT_DIR}/ || true
    rm -f ./boot/Image* || true
    rm -f ./boot/zImage* || true
    rm -f ./boot/vmlinux* || true
    cp -f ${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE_LIVE}*rootfs.cpio.gz ./boot/initrd_boot.cpio.gz
    cd -
    set +x
}
IMAGE_PREPROCESS_COMMAND += "update_cpio_for_ext4;"

sign_copy_distro() {
    set -x
    cd ${WORKDIR}/recipe-sysroot/signtools/build_sign
    EXT4CMS_FILE="Hi3093_ext4fs_cms.bin"
    EXT4_TARGET_BIN="Hi3093_ext4fs.img"
    if [ -e ${EXT4CMS_FILE} ]; then
        rm Hi3093_ext4fs_cms.bin
        rm Hi3093_ext4fs.img
        rm Hi3093_ext4fs.img.g1.cms
        rm Hi3093_ext4fs.img.g2.cms
        rm crldata_g1.crl
    fi
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*ext4 ${EXT4_TARGET_BIN}
    echo "Hi3093" >> Hi3093_ext4fs.img.g1.cms
    echo "Hi3093" >> Hi3093_ext4fs.img.g2.cms
    echo "Hi3093" >> crldata_g1.crl
    export KERNEL_VERSION_MAIN="5.10"
    ./generate_sign_image rootfs_cms.cfg
    dd if=Hi3093_ext4fs_cms.img of=Hi3093_ext4fs_cms.bin bs=1k count=36
    cp -fp ${EXT4_TARGET_BIN} ${OUTPUT_DIR}/
    cp -fp Hi3093_ext4fs_cms.bin ${OUTPUT_DIR}/
    cp -fp ${DEPLOY_DIR_IMAGE}/u-boot_rsa_4096.bin ${OUTPUT_DIR}/
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*cpio.gz ${OUTPUT_DIR}/
    cd -
    set +x
}
IMAGE_POSTPROCESS_COMMAND += "sign_copy_distro;"

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
"

IMAGE_INSTALL += " \
${@bb.utils.contains("DISTRO_FEATURES", "mcs", "packagegroup-mcs", "",d)} \
${@bb.utils.contains("DISTRO_FEATURES", "ros", "packagegroup-ros", "", d)} \
"

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"

