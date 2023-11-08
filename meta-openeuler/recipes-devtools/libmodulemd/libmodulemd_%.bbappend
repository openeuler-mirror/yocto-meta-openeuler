PV = "2.15.0"

SRC_URI = " \
    https://github.com/fedora-modularity/libmodulemd/releases/download/libmodulemd-${PV}/modulemd-${PV}.tar.xz \
"

S = "${WORKDIR}/modulemd-${PV}"

SRC_URI[sha256sum] = "15458323d1d1f614f9e706f623794f95d23e59f4c37deeaa16877463aee34af5"

