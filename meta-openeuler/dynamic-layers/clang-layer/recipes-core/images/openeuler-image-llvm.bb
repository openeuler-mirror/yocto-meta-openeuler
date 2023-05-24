# build an iso image, the live-os uses openeuler-image-live, it must be the same as itself(openeuler-image)
# when LIVE_ROOTFS_TYPE defined, bug may come out in poky, so just use default value ext4 in image-live.bbclass.
# notice we need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES_append_aarch64 = " iso"
IMAGE_FSTYPES_append_x86-64 = " iso"
IMAGE_FSTYPES_remove_raspberrypi4 = "iso"
INITRD_IMAGE_LIVE = "openeuler-image-live"

# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES should be defined before openeuler-image-common.inc(before core-image and image.bbclass)
require recipes-core/images/openeuler-image-common.inc
# package sdk
require recipes-core/images/openeuler-image-sdk.inc
require clang-sdk.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
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

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"
