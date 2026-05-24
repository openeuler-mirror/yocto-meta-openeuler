# qemu-image.bbclass
# For QEMU targets, /boot contents are not used since kernel is loaded by QEMU directly.
# Remove /boot contents to reduce image size.

fakeroot remove_boot_contents() {
    boot_dir="${IMAGE_ROOTFS}/boot"
    if [ -d "${boot_dir}" ]; then
        rm -rf "${boot_dir}"/*
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "remove_boot_contents; "