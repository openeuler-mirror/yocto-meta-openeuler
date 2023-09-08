# main bbfile: meta-openeuler/recipes-graphics/mesa/mesa_23.1.3.bb

require mesa-src.inc

# remove makedepend from DEPENDS since it is rarely used now
DEPENDS:remove = "makedepend-native"

# kmsro: Open source graphics driver, based on gallium
# virgl: Virtual 3D Graphics Acceleration Protocol
PACKAGECONFIG:append = " kmsro virgl"

# ref: meta-raspberrypi/recipes-graphics/mesa/mesa_%.bbappend
PACKAGECONFIG:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11 dri3', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'vulkan', 'vulkan broadcom', '', d)}"
