FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
# fix mkfs.ext4 running error, add -E no_copy_xattrs to mkfs.ext4
WKS_FILE = "sdimage-rpi.wks"
WKS_FILE_DEPENDS = ""

SDIMG_KERNELIMAGE = "Image"

# we need more space for boot: see definition in sdcard_image-rpi.bbclass
BOOT_SPACE = "196608"

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
    # here we want reserved resources for mcs features.
    mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo ::overlays/mcs-resources.dtbo || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/mcs-resources.dtbo into boot.img"
}

# make no login and standard PATH
set_permissions_from_rootfs_append() {
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

    # add mcs dtoverlay config
    dtcfg=`cat ${CONFIGFILE}  | grep mcs-resources || true`
    if [ -z "$dtcfg" ]; then
        echo "dtoverlay=mcs-resources" >> ${CONFIGFILE}
    fi

    #change grub.cfg to use Image.gz to launch
    sed -i 's/linux \/Image /linux \/Image.gz /' ${DEPLOY_DIR_IMAGE}/EFI/BOOT/grub.cfg
    #set maxcpus=3, reserve cpu3 for clientos
    sed -i 's/linux \/Image.gz/& maxcpus=3 /' ${DEPLOY_DIR_IMAGE}/EFI/BOOT/grub.cfg
}

IMAGE_PREPROCESS_COMMAND_append += "change_bootfiles_to_enable_uefi"
