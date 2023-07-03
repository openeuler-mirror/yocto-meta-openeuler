SDIMG_KERNELIMAGE = "Image"

# we need more space for boot: see definition in sdcard_image-rpi.bbclass
BOOT_SPACE = "196608"

RDEPENDS += " \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse-overlay', '', d)} \
"

# Notice: we need our sdcard_image-rpi.bbclass in meta-openeuler-bsp to work.
uefi_configuration() {
    # we use Image.gz for grub.cfg here
    gzip -c "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" > "${DEPLOY_DIR_IMAGE}/Image.gz"
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
    CONFIGFILE=${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt
    # here we want reserved resources for mcs features
    if ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'true', 'false', d)}; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo ::overlays/mcs-resources.dtbo || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo into boot.img"

        # When repeatedly making rpi image, the CONFIGFILE may not be cleaned up.
        # For this reason, first check to see if the CONFIGFILE is configured with dtoverlay. If it is already configured, skip it.
        if ! grep -wq "mcs-resources" ${CONFIGFILE}; then
            echo "dtoverlay=mcs-resources" >> ${CONFIGFILE}
            # overwrite the config.txt
            mcopy -o -v -i ${WORKDIR}/boot.img -s ${CONFIGFILE} ::config.txt || bbfatal "mcopy cannot copy config.txt into boot.img"
        fi
    fi
    # add jailhouse-overlay
    if ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'true', 'false', d)}; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/jailhouse-overlay.dtbo ::overlays/jailhouse-overlay.dtbo || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/jailhouse-overlay.dtbo into boot.img"
        if ! grep -wq "jailhouse-overlay" ${CONFIGFILE}; then
            echo "dtoverlay=jailhouse-overlay" >> ${CONFIGFILE}
            mcopy -o -v -i ${WORKDIR}/boot.img -s ${CONFIGFILE} ::config.txt || bbfatal "mcopy cannot copy config.txt into boot.img"
        fi
    fi
}

# make no login and standard PATH
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    if [ -f ./etc/profile ]; then
        sed -i "s#^PATH=.*#PATH=\"/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin\"#g" ./etc/profile
    fi
    cd -
}

change_bootfiles_to_enable_uefi() {
    CONFIGFILE=${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt

    # change configs to use uefi and load mcs dtoverlay
    eficfg=`cat ${CONFIGFILE}  | grep RPI_EFI || true`
    if [ -z "$eficfg" ]; then
        echo "arm_64bit=1" >> ${CONFIGFILE}
        echo "uart_2ndstage=1" >> ${CONFIGFILE}
        echo "enable_gic=1" >> ${CONFIGFILE}
        echo "armstub=RPI_EFI.fd" >> ${CONFIGFILE}
        echo "disable_commandline_tags=1" >> ${CONFIGFILE}
        echo "disable_overscan=1" >> ${CONFIGFILE}
        echo "device_tree_address=0x1f0000" >> ${CONFIGFILE}
        echo "device_tree_end=0x200000" >> ${CONFIGFILE}
    fi

    #change grub.cfg to use Image.gz to launch
    sed -i 's/linux \/Image /linux \/Image.gz /' ${DEPLOY_DIR_IMAGE}/EFI/BOOT/grub.cfg
}

IMAGE_PREPROCESS_COMMAND:append = "change_bootfiles_to_enable_uefi"
