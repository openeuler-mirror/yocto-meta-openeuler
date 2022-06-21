# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
packagegroup-core-boot-tiny \
"

require recipes-core/images/${MACHINE}.inc
