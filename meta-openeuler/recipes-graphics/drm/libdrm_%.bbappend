# main bb file: yocto-poky/meta/recipes-graphics/drm/libdrm_2.4.104.bb

PV = "2.4.109"

DEPENDS:remove = "python3-native libpthread-stubs"

SRC_URI:prepend = "file://libdrm-make-dri-perms-okay.patch \
		   file://libdrm-2.4.0-no-bc.patch \
"

SRC_URI:remove = "file://0001-meson-Also-search-for-rst2man.py.patch \
"

SRC_URI[sha256sum] = "629352e08c1fe84862ca046598d8a08ce14d26ab25ee1f4704f993d074cb7f26"

# not support intel on arm
PACKAGECONFIG:remove:aarch64 = "intel"
