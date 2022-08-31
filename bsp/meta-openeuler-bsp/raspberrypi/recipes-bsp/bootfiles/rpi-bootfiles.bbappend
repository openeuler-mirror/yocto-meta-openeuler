SRC_URI = "file://raspberrypi-firmware/firmware-1.20220308.tar.gz \
"

S = "${WORKDIR}/firmware-1.20220308/boot"

# add uefi grub package
do_deploy[depends] += " \
    grub-efi:do_deploy \
    grub-bootconf:do_deploy \
    rpi-uefi:do_deploy \
"

# add mcs reseved memory dtoverlay package
do_deploy[depends] += " \
    mcs-memreserve-overlay:do_deploy \
"

