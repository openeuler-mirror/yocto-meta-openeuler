SUMMARY = "Dummy Linux kernel"
DESCRIPTION = "Dummy Linux kernel, to be selected as the preferred \
provider for virtual/kernel to satisfy dependencies for situations \
where you wish to build the kernel externally from the build system."
SECTION = "kernel"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

PACKAGES = "${PN}-dbg catchsegv sln nscd ldconfig ldd tzcode glibc-thread-db ${PN}-pic libcidn libmemusage malloc-debug libnss-db libsegfault ${PN}-pcprofile libsotruss ${PN} ${PN}-utils glibc-extra-nss ${PN}-dev ${PN}-staticdev ${PN}-doc ${PN}-src"

#DEPENDS = "virtual/${TARGET_PREFIX}gcc libgcc-initial linux-libc-headers"
PROVIDES += " \
    virtual/libc \
    virtual/libiconv \
"
PROVIDES += "virtual/libc virtual/libiconv virtual/libintl"
#RPROVIDES_${PN}-dev += "libc-dev"


INHIBIT_DEFAULT_DEPS = "1"

PR = "r1"

require ../../recipes-devtools/gcc/gcc-bin-toolchain.inc
SRC_URI_aarch64 = "file://openeuler_gcc_arm64le"
SRC_URI_arm = "file://openeuler_gcc_arm32le"
#Not strip toolchain
INHIBIT_SYSROOT_STRIP = "1"
#FILESPATH_prepend += "${LOCAL_FILES}:"
DL_DIR = "${LOCAL_SYSROOT_DL_DIR}"
S_aarch64 = "${WORKDIR}/openeuler_gcc_arm64le/sysroot"
S_arm = "${WORKDIR}/openeuler_gcc_arm32le/sysroot"
PSEUDO_DISABLED = "1"
PRIVATE_LIBS_${PN}-dev_append = "libdl.so.2 libresolv.so.2 libm.so.6 librt.so.1 libnsl.so.1 libnss_files.so.2 "

do_configure() {
	:
}

do_compile () {
	:
}

do_install() {
    install -m 0755 -d ${D}/
    cp -pPR ${S}/* ${D}/
    #for f in ${D}${bindir}/${EULER_TOOLCHAIN_SYSNAME}-*; do
    echo "EULER_TOOLCHAIN_SYSNAME:$EULER_TOOLCHAIN_SYSNAME"
    echo "TARGET_PREFIX:$TARGET_PREFIX"
    EULER_TOOLCHAIN_SYSNAME="aarch64-openeuler-linux-gnu"
    EULER_TOOLCHAIN_TARGET_PREFIX="aarch64-openeuler-linux-"
    echo "D:${D}"
    rm -rf ${D}/etc/rpc
    rm -rf ${D}/${base_libdir}/debug
    echo ${libdir}
    echo ${base_libdir}
}

SYSROOT_DIRS += "/*"
#depends by glibc-locale
do_stash_locale() {
        :
}
addtask do_stash_locale
deltask do_package
deltask do_package_write_rpm
#depends by libgcc
do_packagedata () {
        :
}

BBCLASSEXTEND = "native nativesdk"
