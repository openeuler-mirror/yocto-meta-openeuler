FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# fix mkfs.ext4 running error, add -E no_copy_xattrs to mkfs.ext4
WKS_FILE = "sdimage-rpi.wks"
WKS_FILE_DEPENDS = ""

require mcs.inc

# openeuler-image-mcs as the INITRAMFS_IMAGE, set IMAGE_FSTYPES to INITRAMFS_FSTYPES to avoid dependency loops.
IMAGE_FSTYPES = "${@bb.utils.contains('BUILD_GUEST_OS', '1', '${INITRAMFS_FSTYPES}', 'rpi-sdimg', d)}"
