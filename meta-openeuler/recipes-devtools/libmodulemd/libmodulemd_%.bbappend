PV = "2.14.0"

SRC_URI = " \
    https://github.com/fedora-modularity/libmodulemd/releases/download/libmodulemd-${PV}/modulemd-${PV}.tar.xz \
"

S = "${WORKDIR}/modulemd-${PV}"

SRC_URI[sha256sum] = "8087942cc290c0df486931233446fb4bce786cd9ff92eb72384731cd4d36f6ef"

# delete depends to prelink from gobject-introspection.bbclass
DEPENDS:remove:class-target = " prelink-native"
