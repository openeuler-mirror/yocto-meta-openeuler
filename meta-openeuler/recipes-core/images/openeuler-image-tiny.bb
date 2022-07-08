# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "A small image just capable of allowing a device to boot."

require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
"

require recipes-core/images/${MACHINE}.inc
