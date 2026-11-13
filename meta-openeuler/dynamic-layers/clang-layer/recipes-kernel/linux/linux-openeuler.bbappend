TOOLCHAIN = "clang"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# -p is only passed by the kernel6 zImage makefiles (the 6.6 and the
# tag-rpi variants); the 5.10 zImage makefile has no -p at all, so the
# link fix is both unneeded and inapplicable there - guard it to kernel6
SRC_URI:append:aarch64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' file://fix-link-error-unknown-argument.patch', '', d)} \
    "

# the relocation fix applies wherever zImage support creates
# compressed/head.S: the kernel6 trees and the mainline 5.10 tree.
# The 5.10 RPi tree ships no zImage support patch at all (no
# compressed/ directory), so the fix cannot apply there.
SRC_URI:append:aarch64 = " file://fix-out-of-range-error.patch \
        "
SRC_URI:remove:raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'file://fix-out-of-range-error.patch', d)} \
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
