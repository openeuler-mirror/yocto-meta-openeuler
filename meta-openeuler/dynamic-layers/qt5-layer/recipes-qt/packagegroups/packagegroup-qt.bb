SUMMARY = "qt pkgs"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
weston \
weston-examples \
qtwayland \
qtbase \
kmscube \
helloworld-gui \
${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'weston-xwayland gtk+3 gtk+3-demo wxwidgets', 'qt5-opengles2-test', d)} \
"
