PV = "0.63.2"

SRC_URI[sha256sum] = "16222f17ef76be0542c91c07994f9676ae879f46fc21c0c786a21ef2cb518bbf"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://meson-${PV}.tar.gz \
           file://meson-setup.py \
           file://meson-wrapper \
           file://0001-python-module-do-not-manipulate-the-environment-when.patch \
           file://0001-Make-CPU-family-warnings-fatal.patch \
           file://0002-Support-building-allarch-recipes-again.patch \
           file://0001-is_debianlike-always-return-False.patch \
           file://0001-Check-for-clang-before-guessing-gcc-or-lcc.patch \
           "
