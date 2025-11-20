SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc
require mcs-image-common.inc

# basic packages required, e.g., boot, ssh ,debug
# overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-mcs \
"