# Notice: we need CONFIG_VIRTIO_BLK=y CONFIG_EXT4_FS=y for vda ext4 filesystem to setup.
# For x86-64, also relies on CONFIG_ATA_PIIX=y CONFIG_BLK_DEV_SD=y

INSTALLMODULES =+ " \
kernel-module-cdrom \
kernel-module-sr-mod \
kernel-module-isofs \
kernel-module-msdos \
kernel-module-virtiofs \
"
