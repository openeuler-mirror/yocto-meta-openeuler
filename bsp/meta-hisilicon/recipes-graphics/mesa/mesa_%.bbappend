PACKAGECONFIG:append:hi1711 = " gallium vc4 v3d kmsro ${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11 dri3', '', d)}"
