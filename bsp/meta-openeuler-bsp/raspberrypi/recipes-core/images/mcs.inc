SDIMG_KERNELIMAGE = "Image"

# we need more space for boot: see definition in sdcard_image-rpi.bbclass
BOOT_SPACE = "196608"

RDEPENDS += " \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse-overlay', '', d)} \
"

# Notice: we need our sdcard_image-rpi.bbclass in meta-openeuler-bsp to work.
# Install mcs overlays via uefi hook
uefi_configuration:append() {
    # here we want reserved resources for mcs features
    if ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'true', 'false', d)}; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo ::overlays/mcs-resources.dtbo || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo into boot.img"
    fi

    # add jailhouse-overlay
    if ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'true', 'false', d)}; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/jailhouse-overlay.dtbo ::overlays/jailhouse-overlay.dtbo || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/jailhouse-overlay.dtbo into boot.img"
        # overwrite dtb to assign more devices to non-root linux
        if [ "${@bb.utils.contains('BUILD_GUEST_OS', '1', 'yes', 'no', d)}" = "yes" ]; then
            mcopy -v -D o -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/bcm2711-rpi-4-b-jailhouse.dtb ::bcm2711-rpi-4-b.dtb || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/bcm2711-rpi-4-b-jailhouse.dtb into boot.img"
        fi
    fi
}
