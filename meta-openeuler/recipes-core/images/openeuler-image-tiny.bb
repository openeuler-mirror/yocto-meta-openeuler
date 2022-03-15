require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
"

require recipes-core/images/${MACHINE}.inc
