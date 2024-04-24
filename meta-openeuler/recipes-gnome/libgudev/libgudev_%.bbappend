PV = "238"

FILESEXTRAPATHS:append := "${THISDIR}/libgudev/:"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://0001-meson-Pass-export-dynamic-option-to-linker.patch \
"

EXTRA_OEMESON += "-Dtests=disabled -Dvapi=disabled"

