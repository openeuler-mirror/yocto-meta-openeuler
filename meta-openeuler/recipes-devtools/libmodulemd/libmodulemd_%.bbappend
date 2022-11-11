PV = "2.13.0"

SRC_URI = " \
    https://github.com/fedora-modularity/libmodulemd/releases/download/libmodulemd-${PV}/modulemd-${PV}.tar.xz \
"

S = "${WORKDIR}/modulemd-${PV}"

SRC_URI[sha256sum] = "cc72ce5ff48ce9a4f6c9b6606ccf5a0e75c59c35449668cfe985722ef28f9cbc"

# delete depends to prelink from gobject-introspection.bbclass
DEPENDS_remove_class-target = " prelink-native"
