require recipes-core/images/bsp-${MACHINE}.inc

# we need to manually resize the hieulerpi to use the full sdcard
IMAGE_INSTALL += " \
    e2fsprogs-resize2fs \
"
