PV = "1.72.0"

# openEuler-23.03 version is 1.74.0, but gobject-introspection-native depends glib2 at least 2.74 version.
# nativesdk provides glib2 is too old to compile, so do not update package version now.
OPENEULER_BRANCH = "openEuler-22.09"

DEPENDS_remove_class-target = "prelink-native"

# apply new patch for 1.72.0 from poky
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "${GNOME_MIRROR}/${BPN}/${@oe.utils.trim_version("${PV}", 2)}/${BPN}-${PV}.tar.xz \
           file://0001-g-ir-tool-template.in-fix-girdir-path.patch \
           "

SRC_URI[sha256sum] = "02fe8e590861d88f83060dd39cda5ccaa60b2da1d21d0f95499301b186beaabc"

do_configure_append_class-target() {
        # delete prelink-rtld
        cat > ${B}/g-ir-scanner-lddwrapper << EOF
#!/bin/sh
\$OBJDUMP -p "\$@"
EOF
}

RDEPENDS_${PN}_remove_class-native = "python3-pickle python3-xml"
