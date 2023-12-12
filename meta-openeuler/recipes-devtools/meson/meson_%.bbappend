OPENEULER_SRC_URI_REMOVE = "https http"

PV = "1.1.1"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = "${GITHUB_BASE_URI}/download/${PV}/meson-${PV}.tar.gz \
           "
SRC_URI:prepend = "file://meson-${PV}.tar.gz \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
