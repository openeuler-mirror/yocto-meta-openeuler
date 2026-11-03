# main bb file: yocto-poky/meta/recipes-graphics/drm/libdrm_2.4.104.bb

PV = "2.4.119"

DEPENDS:remove = "libpthread-stubs"

SRC_URI:prepend = "file://${BP}.tar.xz \
           file://libdrm-make-dri-perms-okay.patch \
		   file://libdrm-2.4.0-no-bc.patch \
"

# not support intel on arm
PACKAGECONFIG:remove:aarch64 = "intel"
