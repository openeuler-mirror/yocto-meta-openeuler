TOOLCHAIN = "clang"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
SRC_URI:append:aarch64 = " file://fix-link-error-unknown-argument.patch \
        file://fix-out-of-range-error.patch \
        "

# mainline kernel6 tree (kernel-6.6, 180.0.0): entry.S carries the .ifc
# conversion upstream, but the tlbip/tlbid code needs the clang-specific
# preamble and Kconfig fixes
SRC_URI:append:aarch64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' file://fix-tlbip-tlb-rmi-extension.patch file://fix-tlbid-acpi-dependency.patch', '', d)} \
    "

# RPi kernel6 tree (kernel-6.6-tag-rpi) predates both: entry.S still
# uses .if string compares while there is no tlbip/tlbid code at all
SRC_URI:remove:raspberrypi4-64 = "file://fix-tlbip-tlb-rmi-extension.patch file://fix-tlbid-acpi-dependency.patch"
SRC_URI:append:raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' file://fix-asm-ifc-string-compare-rpi.patch', '', d)} \
    "

SRC_URI:append:toolchain-clang = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', \
        ' file://fix-extra-warning-in-clang.patch', d)} \
    "
