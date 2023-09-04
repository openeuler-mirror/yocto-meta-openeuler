OPENEULER_SRC_URI_REMOVE = "http git"

PV = "0.3.113"

# apply package and patches from openeuler
# 0006-libaio-Add-sw64-architecture.patch is conlict, 
# not apply it as we not support sw64 current
SRC_URI:prepend = "file://libaio-${PV}.tar.gz \
           file://0000-libaio-install-to-destdir-slash-usr.patch \
           file://0001-libaio-arm64-ilp32.patch \
           file://0002-libaio-makefile-cflags.patch \
           file://0003-libaio-fix-for-x32.patch \
           file://0004-libaio-makefile-add-D_FORTIFY_SOURCE-flag.patch \
           file://0005-Fix-compile-error-that-exec-checking-need-super-priv.patch \
           file://0007-Fix-build-error-if-compiler-is-clang.patch \
           "

S = "${WORKDIR}/${BPN}-${PV}"

# fix libaio.a install fail, need to set install prefix dir
EXTRA_OEMAKE =+ "usrlibdir=${D}${libdir} "
