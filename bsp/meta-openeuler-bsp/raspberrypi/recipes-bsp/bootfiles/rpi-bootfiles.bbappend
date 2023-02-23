OPENEULER_REPO_NAME = "raspberrypi-firmware"
SRC_URI = "file://firmware-1.20220308.tar.gz \
"

S = "${WORKDIR}/firmware-1.20220308/boot"

# add uefi grub package
do_deploy[depends] += " \
    grub-efi:do_deploy \
    grub-bootconf:do_deploy \
    rpi-uefi:do_deploy \
"

# fix runtime error: Could not find DRM device!
# instead of bcm2711-rpi-4-b.dtb from kernel_devicetree
do_deploy_append() {
    cp ${S}/bcm2711-rpi-4-b.dtb ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
}
