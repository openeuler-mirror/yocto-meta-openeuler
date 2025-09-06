# add bsp depends here, should use for all images(tiny, standard, etc)

# TODO: support ch343 for kernel6
IMAGE_INSTALL:append = " \
hieulerpi1-tf-a \
hieulerpi1-bsp-pkg \
i2c-soft \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'ch343', d)} \
mcu-tool \
"
