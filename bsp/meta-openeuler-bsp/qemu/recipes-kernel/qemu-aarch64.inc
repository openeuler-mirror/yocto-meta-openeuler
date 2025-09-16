SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'oe-xfce', 'file://config/arm64/xfce.cfg', '', d)}"
