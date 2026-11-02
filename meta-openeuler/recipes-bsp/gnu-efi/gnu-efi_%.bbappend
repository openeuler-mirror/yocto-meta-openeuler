# main bbfile: yocto-poky/meta/recipes-bsp/gnu-efi/gnu-efi_3.0.14.bb

PV = "3.0.19"

SRC_URI =+ "file://${PV}.tar.gz "

# patches from openeuler spec (src-openeuler repo)
SRC_URI:append = " \
    file://0001-gnu-efi-add-CHAR16-for-loongarch64.patch \
    file://0001-Add-support-for-SW64.patch \
    file://no-werror.patch \
"

# poky patches not applicable to 3.0.19
SRC_URI:remove = " \
    file://lib-Makefile-fix-parallel-issue.patch \
    file://parallel-make-archives.patch \
    file://gnu-efi-3.0.9-fix-clang-build.patch \
"

do_compile:prepend() {
    unset LDFLAGS
}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

FILES:${PN} += "${libdir}/gnuefi/apps"

SRC_URI:riscv64:append = " \
    file://riscv64-fix-efibind.h-missing-duplicate-types.patch \
"
