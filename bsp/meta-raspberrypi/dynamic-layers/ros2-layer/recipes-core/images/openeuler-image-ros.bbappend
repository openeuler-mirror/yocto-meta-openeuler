FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
#fix mkfs.ext4 running error, add -E no_copy_xattrs to mkfs.ext4
WKS_FILE = "sdimage-rpi.wks"
WKS_FILE_DEPENDS = ""

# add ros slam demo for rpi4
IMAGE_INSTALL += " \
packagegroup-rosslam \
packagegroup-roscamera \
"