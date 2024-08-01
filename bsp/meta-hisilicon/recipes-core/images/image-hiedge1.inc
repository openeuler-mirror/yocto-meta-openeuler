# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included in live image

require recipes-core/images/bsp-${MACHINE}.inc

# all app and tools
IMAGE_INSTALL += " \
hiedge1-user-driver \
"


# 1. dsoftbus is not adpated to hieulerpi1
# 2. user-driver may provides libsecurec.so,
#  it conflicts with libboundscheck, especially in SDK
# so, remove dsoftbus from IMAGE_INSTALL
IMAGE_INSTALL:remove = " \
    packagegroup-dsoftbus \
"
