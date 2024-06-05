# install initrd into boot.img
DEPLOYPAYLOAD = "${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}:initrd"
RPI_SDIMG_EXTRA_DEPENDS:append = "${INITRAMFS_IMAGE}:do_image_complete"
