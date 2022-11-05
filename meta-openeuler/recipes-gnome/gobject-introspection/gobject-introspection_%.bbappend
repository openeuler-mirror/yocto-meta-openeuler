# main bb file: yocto-poky/meta/recipes-gnome/gobject-introspection/gobject-introspection_1.66.1.bb

PV = "1.70.0"

# this patch has been merged into this version
SRC_URI_remove = "file://0001-meson.build-exclude-girepo_dep-if-introspection-data.patch \
"

SRC_URI[md5sum] = "940ea2d6b92efabc457b9c54ce2ff398"
SRC_URI[sha256sum] = "902b4906e3102d17aa2fcb6dad1c19971c70f2a82a159ddc4a94df73a3cafc4a"

# use nativesdk's python3
RDEPENDS_${PN}_remove_class-native = "python3-pickle python3-xml"
