# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included in live image

require recipes-core/images/bsp-${MACHINE}.inc

# all app and tools
IMAGE_INSTALL += " \
"


# some packages to be removed from IMAGE_INSTALL
IMAGE_INSTALL:remove = " \
"
