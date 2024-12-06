do_install:append() {
    if [ ! -d "/boot/EFI/euleros" ]; then
        sed -i '/umount \/boot/i\cp -rf /boot/EFI/BOOT /boot/EFI/euleros;cp /boot/EFI/euleros/bootaa64.efi /boot/EFI/euleros/grubaa64.efi' ${WORKDIR}/init-install-efi-openeuler.sh
        sed -i '/umount \/boot/i\cp -rf /boot/EFI/BOOT /boot/EFI/euleros;cp /boot/EFI/euleros/bootaa64.efi /boot/EFI/euleros/grubaa64.efi' ${D}/init.d/install-efi.sh
    fi
}
