require recipes-core/images/image-${MACHINE}.inc

OEBRIDGE_IBROBOT_SCRIPT := "${@bb.utils.contains('DISTRO_FEATURES', 'ibrobot', bb.utils.contains('DISTRO_FEATURES', 'ibrobot-dev', 'oebridge-extra-command.sh', 'oebridge-extra-command-ibrobot.sh', d), 'oebridge-extra-command.sh', d)}"
OEBRIDGE_IBROBOT_PRE_SCRIPT := "${@bb.utils.contains('DISTRO_FEATURES', 'ibrobot', bb.utils.contains('DISTRO_FEATURES', 'ibrobot-dev', 'oebridge-extra-command_pre_hostenv.sh', 'oebridge-extra-command-ibrobot_pre_hostenv.sh', d), 'oebridge-extra-command_pre_hostenv.sh', d)}"
OEBRIDGE_IBROBOT_POST_SCRIPT := "${@bb.utils.contains('DISTRO_FEATURES', 'ibrobot', bb.utils.contains('DISTRO_FEATURES', 'ibrobot-dev', 'oebridge-extra-command_post_hostenv.sh', 'oebridge-extra-command-ibrobot_post_hostenv.sh', d), 'oebridge-extra-command_post_hostenv.sh', d)}"

OEBRIDGE_EXTRA_FILE_PATH := "${THISDIR}/files/${OEBRIDGE_IBROBOT_SCRIPT}"
OEBRIDGE_EXTRA_PRE_HOSTENV_FILE_PATH := "${THISDIR}/files/${OEBRIDGE_IBROBOT_PRE_SCRIPT}"
OEBRIDGE_EXTRA_POST_HOSTENV_FILE_PATH := "${THISDIR}/files/${OEBRIDGE_IBROBOT_POST_SCRIPT}"
