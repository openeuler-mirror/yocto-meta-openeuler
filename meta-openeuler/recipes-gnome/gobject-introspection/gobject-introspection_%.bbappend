# main bb file: yocto-poky/meta/recipes-gnome/gobject-introspection/gobject-introspection_1.66.1.bb
PV = "1.70.0"

OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# this patch has been merged into this version
SRC_URI_remove = " \
    file://0001-giscanner-ignore-error-return-codes-from-ldd-wrapper.patch \
    file://0001-meson.build-exclude-girepo_dep-if-introspection-data.patch \
"

SRC_URI += " \
    file://gobject-introspection-${PV}.tar.xz \
    file://0001-build-Avoid-the-doctemplates-hack.patch \
"

# use nativesdk's python3
RDEPENDS_${PN}_remove_class-native = "python3-pickle python3-xml"

DEPENDS_remove_class-target = "prelink-native"

do_configure_append_class-target() {
        # delete prelink-rtld
        cat > ${B}/g-ir-scanner-lddwrapper << EOF
#!/bin/sh
\$OBJDUMP -p "\$@"
EOF
}
