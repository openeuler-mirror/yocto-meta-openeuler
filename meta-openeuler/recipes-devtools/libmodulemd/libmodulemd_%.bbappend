PV = "2.13.0"

SRC_URI = " \
    file://modulemd-${PV}.tar.xz \
"

S = "${WORKDIR}/modulemd-${PV}"

SRC_URI[sha256sum] = "8087942cc290c0df486931233446fb4bce786cd9ff92eb72384731cd4d36f6ef"

# delete depends to prelink from gobject-introspection.bbclass
DEPENDS_remove_class-target = " prelink-native"
