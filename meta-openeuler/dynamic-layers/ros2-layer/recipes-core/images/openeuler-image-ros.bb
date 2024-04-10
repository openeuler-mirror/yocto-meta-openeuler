# build an iso image, the live-os uses openeuler-image-live, it must be the same as itself(openeuler-image)
# when LIVE_ROOTFS_TYPE defined, bug may come out in poky, so just use default value ext4 in image-live.bbclass.
# notice we need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES:append:aarch64 = " iso"
IMAGE_FSTYPES:remove:raspberrypi4 = "iso"

include recipes-core/images/image-early-config-${MACHINE}.inc
# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES should be defined before openeuler-image-common.inc(before core-image and image.bbclass)
require recipes-core/images/openeuler-image-common.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put other class of packages to "packagegroup-xxx"
# Notice: IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
IMAGE_INSTALL += " \
packagegroup-roscore \
"
# current qemu can't support ros slam demo

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"

require ros-sdk-base.inc

