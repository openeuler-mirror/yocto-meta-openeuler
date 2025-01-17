# main bbfile: meta-openeuler/recipes-graphics/mesa/mesa_24.0.3.bb

require mesa-src.inc

# remove makedepend from DEPENDS since it is rarely used now
DEPENDS:remove = "makedepend-native"

# kmsro: Open source graphics driver, based on gallium
# virgl: Virtual 3D Graphics Acceleration Protocol
# r600: amd r series graphics driver
PACKAGECONFIG:append = " kmsro virgl r600 "

# ref: meta-raspberrypi/recipes-graphics/mesa/mesa_%.bbappend
PACKAGECONFIG:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11 dri3', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'vulkan', 'vulkan broadcom', '', d)}"
