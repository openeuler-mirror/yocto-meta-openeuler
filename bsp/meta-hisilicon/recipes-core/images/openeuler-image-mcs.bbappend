# Zephyr and Jailhouse do not currently support hi3093, so remove them.
IMAGE_INSTALL_remove = " \
    zephyr-image \
    ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} \
    "
