SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc
require openeuler-image-sdk.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
mcs-linux \
mcs-km \
screen \
libgcc-external \
zephyr-image \
"
