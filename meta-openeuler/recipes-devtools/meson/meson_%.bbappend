PV = "1.3.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
SRC_URI = "file://${PV}.tar.gz \
           file://meson-setup.py \
           file://meson-wrapper \
           file://0001-python-module-do-not-manipulate-the-environment-when.patch \
           file://0001-Make-CPU-family-warnings-fatal.patch \
           file://0002-Support-building-allarch-recipes-again.patch \
"
SRC_URI[sha256sum] = "6020568bdede1643d4fb41e28215be38eff5d52da28ac7d125457c59e0032ad7"
