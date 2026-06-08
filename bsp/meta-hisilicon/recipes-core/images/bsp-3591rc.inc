# add bsp depends here, should use for all images(tiny, standard, etc)

IMAGE_INSTALL:append = " \
    fake-hwclock \
    ${@bb.utils.contains('DISTRO_FEATURES', '3591fullimg', ' \
        3591-bsp-pkg \
        3591-expand-fs \
    ', ' \
         \
    ', d)} \
"
