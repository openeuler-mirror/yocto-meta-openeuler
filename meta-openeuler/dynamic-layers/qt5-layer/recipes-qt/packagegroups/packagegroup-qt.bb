SUMMARY = "qt pkgs"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
weston \
qtwayland \
qtbase \
kmscube \
qt5-opengles2-test \
helloworld-gui \
"
