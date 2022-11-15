PV = "0.61.5"

SRC_URI[sha256sum] = "182c53d906ced00b903a3ba5b4c4fac86f739c6d2d588d505596962c6ab68f67"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "https://github.com/mesonbuild/meson/releases/download/${PV}/meson-${PV}.tar.gz \
           file://meson-setup.py \
           file://meson-wrapper \
           file://0001-python-module-do-not-manipulate-the-environment-when.patch \
           file://disable-rpath-handling.patch \
           file://0001-is_debianlike-always-return-False.patch \
           file://0001-Check-for-clang-before-guessing-gcc-or-lcc.patch \
           "
