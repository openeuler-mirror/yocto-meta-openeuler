# main bb file: yocto-poky/meta/recipes-graphics/drm/libdrm_2.4.104.bb

PV = "2.4.109"

DEPENDS_remove = "python3-native libpthread-stubs"
PACKAGECONFIG_remove = "intel"

SRC_URI_prepend = "file://libdrm-make-dri-perms-okay.patch \
		   file://libdrm-2.4.0-no-bc.patch \
"

SRC_URI_remove = "file://0001-meson-Also-search-for-rst2man.py.patch \
"

SRC_URI[sha256sum] = "629352e08c1fe84862ca046598d8a08ce14d26ab25ee1f4704f993d074cb7f26"
