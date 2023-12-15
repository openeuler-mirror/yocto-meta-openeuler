OPENEULER_SRC_URI_REMOVE = "https"

PV = "4.4.1"

LIC_FILES_CHKSUM = "file://COPYING;md5=c678957b0c8e964aa6c70fd77641a71e"

SRC_URI:remove = "file://0002-modules-fcntl-allow-being-detected-by-importing-proj.patch \
           file://0001-src-dir.c-fix-buffer-overflow-warning.patch \
           file://0002-w32-compat-dirent.c-follow-header.patch \
           file://0003-posixfcn-fcntl-gnulib-make-emulated.patch \
           file://0001-makeinst-Do-not-undef-POSIX-on-clang-arm.patch \
           "

# apply openeuler source package and patches
SRC_URI:prepend = "file://make-${PV}.tar.gz \
"

# keep same as upstream
# Otherwise $CXX leaks into /usr/bin/make
do_configure:prepend() {
    unset CXX
}
