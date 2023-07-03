PACKAGECONFIG:append:rk3568 = " gallium vc4 v3d kmsro ${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11 dri3', '', d)}"
