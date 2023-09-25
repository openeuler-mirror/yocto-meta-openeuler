SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc
require openeuler-image-sdk.inc

inherit features_check
REQUIRED_DISTRO_FEATURES = "mcs"

# basic packages required, e.g., boot, ssh ,debug
# overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-openssh \
packagegroup-mcs \
"

# openeuler-image-mcs is used for mcs development,
# so enable debug-tweaks
OPENEULER_IMAGE_FEATURES = "debug-tweaks"
