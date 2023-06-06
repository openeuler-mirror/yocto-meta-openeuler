# main bb yocto-poky/meta/recipes-support/libffi/libffi_3.3.bb

PV = "3.4.2"

LIC_FILES_CHKSUM = "file://LICENSE;md5=679b5c9bdc79a2b93ee574e193e7a7bc"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
    file://backport-x86-64-Always-double-jump-table-slot-size-for-CET-71.patch \
    file://backport-Fix-check-for-invalid-varargs-arguments-707.patch \
    file://libffi-Add-sw64-architecture.patch \
    file://backport-Fix-signed-vs-unsigned-comparison.patch \
    file://riscv-extend-return-types-smaller-than-ffi_arg-680.patch \
    file://fix-AARCH64EB-support.patch \
"

# add patch from poky with 3.4.2 version
SRC_URI_append = " \
    file://0001-arm-sysv-reverted-clang-VFP-mitigation.patch \
"

SRC_URI[md5sum] = "294b921e6cf9ab0fbaea4b639f8fdbe8"
SRC_URI[sha256sum] = "540fb721619a6aba3bdeef7d940d8e9e0e6d2c193595bc243241b77ff9e93620"

EXTRA_OECONF += "--disable-builddir --disable-exec-static-tramp"
