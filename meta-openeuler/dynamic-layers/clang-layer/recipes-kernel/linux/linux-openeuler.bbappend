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

SRC_URI:append:toolchain-clang = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', \
        ' file://fix-extra-warning-in-clang.patch', d)} \
    "
