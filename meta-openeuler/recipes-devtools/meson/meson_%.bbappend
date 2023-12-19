# the SP3 version of meson fallbacks to 0.59.4 version
# which cannot be used to build p11-kit
# Thus, we keep the version unchanged compared to SP2
PV = "0.63.2"

SRC_URI[sha256sum] = "16222f17ef76be0542c91c07994f9676ae879f46fc21c0c786a21ef2cb518bbf"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "file://${BP}.tar.gz \
"

# p11-kit requires a higher version of meson
# than the one provided by nativesdk, which has
# the version 0.61.5.
# However, if we use a higher version of meson
# to provide native package, it will break the build of systemd.
PROVIDES_append_class-native = " meson-replacement-native"