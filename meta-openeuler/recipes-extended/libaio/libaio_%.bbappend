#apply package and patches from openeuler
SRC_URI = " \
    file://libaio-0.3.112.tar.gz \
    file://0000-libaio-install-to-destdir-slash-usr.patch \
    file://0001-libaio-arm64-ilp32.patch \
    file://0002-libaio-makefile-cflags.patch \
    file://0003-libaio-fix-for-x32.patch \
    file://0004-libaio-makefile-add-D_FORTIFY_SOURCE-flag.patch \
    file://0005-Fix-compile-error-that-exec-checking-need-super-priv.patch \
"

SRC_URI[sha256sum] = "ab0462f2c9d546683e5147b1ce9c195fe95d07fac5bf362f6c01637955c3b492"

S = "${WORKDIR}/${BPN}-${PV}"

# fix libaio.a install fail, need to set install prefix dir
EXTRA_OEMAKE =+ "usrlibdir=${D}${libdir}"
