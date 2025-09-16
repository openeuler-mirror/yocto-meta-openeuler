FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'oe-xfce', 'file://cfgs/xfce.cfg', '', d)}"
