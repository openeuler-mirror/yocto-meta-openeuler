PV = "0.63.2"

SRC_URI[sha256sum] = "16222f17ef76be0542c91c07994f9676ae879f46fc21c0c786a21ef2cb518bbf"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "https://github.com/mesonbuild/meson/releases/download/${PV}/meson-${PV}.tar.gz \
           "
