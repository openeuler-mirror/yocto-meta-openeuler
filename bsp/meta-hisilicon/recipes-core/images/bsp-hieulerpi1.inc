# add bsp depends here, should use for all images(tiny, standard, etc)

# TODO: support ch343 for kernel6
IMAGE_INSTALL:append = " \
hieulerpi1-tf-a \
hieulerpi1-bsp-pkg \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    hieulerpi1-peripherals-driver \
    hieulerpi1-peripherals-sample \
    hieulerpi1-mpp-sample \
', ' \
    i2c-soft \
    ch343 \
    mcu-tool \
', d)} \
"
