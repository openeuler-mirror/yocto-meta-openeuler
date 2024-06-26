SDIMG_KERNELIMAGE = "Image"

# we need more space for boot: see definition in sdcard_image-rpi.bbclass
BOOT_SPACE = "196608"

RDEPENDS += " \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse-overlay', '', d)} \
"

# Notice: we need our sdcard_image-rpi.bbclass in meta-openeuler-bsp to work.
uefi_configuration() {
    # we use Image.gz for grub.cfg here
    if [ ! -z "${INITRAMFS_IMAGE}" -a "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
        gzip -c "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_LINK_NAME}.bin" > "${DEPLOY_DIR_IMAGE}/Image.gz"
    else
        gzip -c "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" > "${DEPLOY_DIR_IMAGE}/Image.gz"
    fi

    mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/Image.gz ::Image.gz || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/Image.gz into boot.img"
    # here we want uefi to boot
    mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/RPI_EFI.fd ::RPI_EFI.fd || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/RPI_EFI.fd into boot.img"
    # here we use efi and grub to boot
    mmd -i ${WORKDIR}/boot.img EFI
    mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/EFI/* ::EFI/ || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/EFI/* into boot.img"

    # Install mcs overlays via uefi hook
    install_mcs_overlays
}

install_mcs_overlays() {
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
