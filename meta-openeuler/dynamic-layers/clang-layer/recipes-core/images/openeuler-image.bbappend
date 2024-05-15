require clang-sdk.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put other class of packages to "packagegroup-xxx"
# Notice: IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
IMAGE_INSTALL += " \
"

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"
