PV = "1.72.0"

# openEuler-23.03 version is 1.74.0, but gobject-introspection-native depends glib2 at least 2.74 version.
# nativesdk provides glib2 is too old to compile, so do not update package version now.

RDEPENDS:${PN}:remove:class-native = "${@['', 'python3-pickle python3-xml']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"
