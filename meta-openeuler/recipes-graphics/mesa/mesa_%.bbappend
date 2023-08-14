# main bbfile: yocto-poky/meta/recipes-graphics/mesa/mesa_21.0.3.bb

# version in openEuler
PV = "21.3.1"

require mesa-${PV}.inc

LIC_FILES_CHKSUM = "file://docs/license.rst;md5=17a4ea65de7a9ab42437f3131e616a7f"

# add patch search path
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# remove makedepend from DEPENDS since it is rarely used now
DEPENDS:remove = "makedepend-native"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        file://0002-meson.build-make-TLS-ELF-optional.patch \
        file://0001-gallium-dri-Make-YUV-formats-we-re-going-to-emulate-.patch \
        file://0001-Revert-egl-wayland-deprecate-drm_handle_format-and-d.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://backport-fix-build-err-on-arm.patch \
        file://0001-evergreen-big-endian.patch \
        file://mesa-21.3.1-meson.build-make-TLS-ELF-optional.patch \
"

SRC_URI[sha256sum] = "2b0dc2540cb192525741d00f706dbc4586349185dafc65729c7fda0800cc474d"

# ref: mesa_21.3.1.bb
DRIDRIVERS ??= ""
DRIDRIVERS:append:x86-64:class-target = ",r100,r200,nouveau,i965"

# kmsro: Open source graphics driver, based on gallium
# virgl: Virtual 3D Graphics Acceleration Protocol
PACKAGECONFIG:append = " kmsro virgl"
