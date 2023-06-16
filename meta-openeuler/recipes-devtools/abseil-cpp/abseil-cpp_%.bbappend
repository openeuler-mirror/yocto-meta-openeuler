OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "20220623.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI = "file://abseil-cpp-${PV}.tar.gz \
        file://0001-absl-always-use-asm-sgidefs.h.patch \
        file://0002-Remove-maes-option-from-cross-compilation.patch \
        file://abseil-ppc-fixes.patch \
        file://0003-Remove-neon-option-from-cross-compilation.patch \
        "

SRC_URI += " \
        file://backport-Do-not-leak-maes-msse4.1-into-pkgconfig.patch \
        file://abseil-cpp-20210324.2-sw.patch \
        "

S = "${WORKDIR}/abseil-cpp-${PV}"

# contains symbol link
INSANE_SKIP_${PN} += "dev-so"
FILES:${PN} += "${libdir}/libabsl_*.so*"
FILES:${PN}-dev += "${libdir}/pkgconfig"
