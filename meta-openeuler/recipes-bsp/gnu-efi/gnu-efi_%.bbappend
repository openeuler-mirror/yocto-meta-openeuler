# main bbfile: yocto-poky/meta/recipes-bsp/gnu-efi/gnu-efi_3.0.12.bb

PV = "3.0.17"

SRC_URI =+ "file://${BP}.tar.bz2 "

# new configuration for version 3.0.17
do_compile:prepend() {
    unset LDFLAGS
}

FILES:${PN} += "${libdir}/gnuefi/apps"

SRC_URI:riscv64:append = " \
    file://riscv64-fix-efibind.h-missing-duplicate-types.patch \
"