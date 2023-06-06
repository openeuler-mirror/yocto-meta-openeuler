OPENEULER_REPO_NAME = "raspberrypi-firmware"
PV = "1.20230306"
SRC_URI = "file://firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/firmware-${PV}/boot"

# add uefi grub package
# rpi-tf-a package don't support clang compile
# and only the mcs feature depends on uefi and grub.
do_deploy[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'grub-efi:do_deploy grub-bootconf:do_deploy rpi-uefi:do_deploy', '', d)}"

# fix runtime error: Could not find DRM device!
# instead of bcm2711-rpi-4-b.dtb from kernel_devicetree
do_deploy_append() {
    cp ${S}/bcm2711-rpi-4-b.dtb ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
}

inherit ${@bb.utils.contains('MCS_FEATURES', 'lopper-devicetree', 'lopper-devicetree', '', d)}

INPUT_DT = "${S}/bcm2711-rpi-4-b.dtb"
OUTPUT_DT = "${S}/bcm2711-rpi-4-b.dtb"
