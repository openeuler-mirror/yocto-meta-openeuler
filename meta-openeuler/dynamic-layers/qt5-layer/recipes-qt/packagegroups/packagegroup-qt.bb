SUMMARY = "qt pkgs"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
weston \
qtwayland \
qtbase \
kmscube \
${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'gtk+3 wxwidgets', 'qt5-opengles2-test', d)} \
helloworld-gui \
"
