SUMMARY = "packages for hmi feature of openEuler Embedded"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
qtwebbrowser \
wayfire \
pcmanfm \
lxterminal \
lxtask \
gpicview \
l3afpad \
${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'udev-extraconf', d)} \
adwaita-icon-theme \
ttf-wqy-zenhei \
firefox-bin \
"

