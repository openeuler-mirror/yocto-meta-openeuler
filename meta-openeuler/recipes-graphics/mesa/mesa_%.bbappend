# main bbfile: yocto-poky/meta/recipes-graphics/mesa/mesa_21.0.3.bb
OPENEULER_SRC_URI_REMOVE = "https"
# version in openEuler
PV = "21.3.1"

LIC_FILES_CHKSUM = "file://docs/license.rst;md5=17a4ea65de7a9ab42437f3131e616a7f"

# add patch search path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# remove makedepend from DEPENDS since it is rarely used now
DEPENDS_remove = "makedepend-native"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        file://0002-meson.build-make-TLS-ELF-optional.patch \
        file://0001-gallium-dri-Make-YUV-formats-we-re-going-to-emulate-.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://${BP}.tar.xz \
        file://backport-fix-build-err-on-arm.patch \
        file://0001-evergreen-big-endian.patch \
        file://mesa-21.3.1-meson.build-make-TLS-ELF-optional.patch \
"

SRC_URI[sha256sum] = "2b0dc2540cb192525741d00f706dbc4586349185dafc65729c7fda0800cc474d"
