# version 21.3.1 require

PACKAGECONFIG:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', ' dri gallium', '', d)} \
    "

PACKAGECONFIG[dri] = "-Ddri-drivers=${@strip_comma('${DRIDRIVERS}')}, -Ddri-drivers='', xorgproto libdrm"
