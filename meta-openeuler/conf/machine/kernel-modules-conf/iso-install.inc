# Notice: we need CONFIG_VIRTIO_BLK=y CONFIG_EXT4_FS=y for vda ext4 filesystem to setup.

INSTALLMODULES =+ " \
kernel-module-cdrom \
kernel-module-sr-mod \
kernel-module-isofs \
kernel-module-msdos \
kernel-module-virtio-scsi \
kernel-module-virtiofs \
kernel-module-scsi-mod \
kernel-module-sd-mod \
"
