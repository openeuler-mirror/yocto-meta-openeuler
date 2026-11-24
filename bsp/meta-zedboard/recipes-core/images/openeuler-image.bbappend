# IMAGE_BOOT_FILES (boot.bin, u-boot.img, zImage, dtb, boot.scr, bitstream)
# are collected from DEPLOY_DIR_IMAGE by the wic bootimg-partition source.
do_image_wic[depends] += "u-boot:do_deploy virtual/kernel:do_deploy zedboard-bootfiles:do_deploy"

# ZedBoard on-board OLED driver (external module); loaded by the PL service
# after the bitstream is programmed, so its init sequence reaches the panel.
IMAGE_INSTALL:append = " pmodoled-gpio zedboard-pl zedboard-plfw zedboard-tools"

# Direct Ethernet link to the PC has no default gateway, so the network is
# usable immediately but never "routable": the wait-online unit would only
# fail at boot. Mask it for this board.
zedboard_mask_wait_online() {
    install -d ${IMAGE_ROOTFS}${sysconfdir}/systemd/system
    ln -sf /dev/null ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/systemd-networkd-wait-online.service
}
ROOTFS_POSTPROCESS_COMMAND += "zedboard_mask_wait_online;"