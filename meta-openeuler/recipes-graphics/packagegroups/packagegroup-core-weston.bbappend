# no wayland-utils src on openEuler
RDEPENDS:${PN}:remove = "\
    wayland-utils \
    "

RDEPENDS:${PN}:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'kmscube', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland gtk+3 gtk+3-demo wxwidgets', '', d)} \
"
