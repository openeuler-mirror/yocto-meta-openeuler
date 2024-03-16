SUMMARY = "qt pkgs"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
    qtbase \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'qtwayland', '', d)} \
"

# graphics demo app
RDEPENDS:${PN}:append = "\
    helloworld-gui \
    "
