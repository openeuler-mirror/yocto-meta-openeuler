# image configuration for x86-64
require qemu.inc

# Create an iso image. The openeuler-image-live as the live-os.
# When LIVE_ROOTFS_TYPE defined, bug may come out in poky, so just use default value ext4 in image-live.bbclass.
# Notice: We need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES:append = " iso"
INITRD_IMAGE_LIVE = "openeuler-image-live"
