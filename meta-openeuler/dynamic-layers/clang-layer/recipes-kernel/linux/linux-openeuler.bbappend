TOOLCHAIN = "clang"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# Both patches touch the compressed-image files created by the zImage
# support patches (which pass LDFLAGS_vmlinux += -p to the linker and
# use the large-immediate relocation add). They apply to the mainline
# 5.10 tree (exact pre-image) and to the kernel6 trees.
SRC_URI:append:aarch64 = " file://fix-link-error-unknown-argument.patch \
        file://fix-out-of-range-error.patch \
        "

# The 5.10 RPi tree ships no zImage support patch at all - no
# compressed/ directory is created, so neither patch can apply there.
SRC_URI:remove:raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', \
        'file://fix-link-error-unknown-argument.patch file://fix-out-of-range-error.patch', d)} \
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
