require openeuler-image-common.inc
#package sdk
require openeuler-image-sdk.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put stantard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put extended packages to "packagegroup-base-extended"
# put other class of packages to "packagegroup-xxx"
IMAGE_INSTALL += " \
packagegroup-core-boot \
packagegroup-core-base-utils \
packagegroup-core-tools-debug \
packagegroup-base \
packagegroup-base-extended \
packagegroup-openssh \
packagegroup-kernel-modules \
"
#thie packagegroup should add after refactor
#packagegroup-isulad

require recipes-core/images/${MACHINE}.inc
