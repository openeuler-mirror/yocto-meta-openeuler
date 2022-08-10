# Note IMAGE_FSTYPES defination should before openeuler-image-common.inc(before inherit core-iamge/image.bbclass)
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
#delete depends to cpio-native, use nativesdk's cpio
do_image_cpio[depends] = ""

# build an iso image, the live-os use openeuler-image-live, it musn't the same as itself(openeuler-image)
# when defined LIVE_ROOTFS_TYPE, bug may occered in poky, so just use default value ext4 in image-live.bbclass.
# notice we need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES_aarch64 += " iso "
IMAGE_FSTYPES_x86-64 += " iso "
INITRD_IMAGE_LIVE = "openeuler-image-live"

# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES shuold defined befor openeuler-image-common.inc(before core-image and image.bbclass)
require recipes-core/images/${MACHINE}.inc
require openeuler-image-common.inc
#package sdk
require openeuler-image-sdk.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put stantard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put extended packages to "packagegroup-base-extended"
# put other class of packages to "packagegroup-xxx"
# Notice: IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
IMAGE_INSTALL += " \
packagegroup-core-boot \
packagegroup-core-base-utils \
packagegroup-core-tools-debug \
packagegroup-base \
packagegroup-base-extended \
packagegroup-openssh \
packagegroup-kernel-modules \
packagegroup-isulad \
"
#thie packagegroup should add after refactor

inherit extrausers
EXTRA_USERS_PARAMS = "\
    useradd -p '' openeuler; \
    "

