# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES is recommended to be defined before openeuler-image-common.inc, 
# because openeuler-image-common.inc inlcude core-image.bbclass, and image.bbclass in core-image.bbclass
# will traverse the type of IMAGE_FSTYPES to include the image-${FSTYPE}.class corresponding to the type,
# so if we have special IMAGE_FSTYPES, such as live, IMAGE_FSTYPES needs to be clearly defined in advance,
# otherwise, the following error will occur:
#   No IMAGE_CMD defined for IMAGE_FSTYPES entry 'xxx' - possibly invalid type name or missing support class
# Here we provide configuration file image-early-config-${MACHINE}.inc to accommodate the variables that need
# to be defined in advance as mentioned above
include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put other class of packages to "packagegroup-xxx"
#
# Notice:
#   IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
#   Generic packages are recommended to be defined in openeuler-image-common.inc.
#   If the package is related to a specific IMAGE_FEATURES or DISTRO_FEATURES,
#   it is recommended to add this via image.bb
IMAGE_INSTALL += " \
${@bb.utils.contains("DISTRO_FEATURES", "mcs", "packagegroup-mcs", "",d)} \
${@bb.utils.contains("DISTRO_FEATURES", "ros", "packagegroup-ros", "", d)} \
${@bb.utils.contains("DISTRO_FEATURES", "hmi", "packagegroup-hmi", "", d)} \
${@bb.utils.contains("DISTRO_FEATURES", "kubeedge isulad", "packagegroup-kubeedge", "", d)} \
${@bb.utils.contains("DISTRO_FEATURES", "isulad", "packagegroup-isulad", "", d)} \
"

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"
