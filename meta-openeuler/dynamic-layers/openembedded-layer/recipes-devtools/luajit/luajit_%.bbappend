# version higher on upstream
PV = "2.1.0-beta3"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=076b97f5c7e61532f7f6f3865f04da57"

SRC_URI:prepend = "file://LuaJIT-${PV}.tar.gz \
    file://luajit-2.1-d06beb0-update.patch \
    file://0002-luajit-add-secure-compile-option-fstack.patch \
    file://add-riscv-support.patch \
    "

# patch from meta-oe
SRC_URI:remove = "file://clang.patch"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://0001-Use-builtin-for-clear_cache.patch \
    "

S = "${WORKDIR}/LuaJIT-${PV}"
