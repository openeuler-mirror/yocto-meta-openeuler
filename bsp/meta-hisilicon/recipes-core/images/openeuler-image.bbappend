require recipes-core/images/image-${MACHINE}.inc

OEBRIDGE_EXTRA_FILE_PATH := "${THISDIR}/files/${@bb.utils.contains('DISTRO_FEATURES', 'ibrobot', 'oebridge-extra-command-ibrobot.sh', 'oebridge-extra-command.sh', d)}"
OEBRIDGE_EXTRA_PRE_HOSTENV_FILE_PATH := "${THISDIR}/files/${@bb.utils.contains('DISTRO_FEATURES', 'ibrobot', 'oebridge-extra-command-ibrobot_pre_hostenv.sh', 'oebridge-extra-command_pre_hostenv.sh', d)}"
