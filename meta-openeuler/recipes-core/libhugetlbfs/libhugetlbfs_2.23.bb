SUMMARY = "A library which provides easy access to huge pages of memory"
HOMEPAGE = "https://github.com/libhugetlbfs/libhugetlbfs"
LICENSE = "LGPL-2.1"
LIC_FILES_CHKSUM = "file://LGPL-2.1;md5=2d5025d4aa3495befef8f17206a5b0a1"

SRC_URI = "file://libhugetlbfs/${BP}.tar.gz \
           file://libhugetlbfs/0000-build_flags.patch \
           file://libhugetlbfs/Disable-hugepage-backed-malloc-if-__morecore-is-not-.patch \
           file://libhugetlbfs/libhugetlbfs-make-cflags.patch \
"
SRC_URI[sha256sum] = "b70672f1e807c61b7eb3adf41c1903b42917951f2e7f8aef6821841700c04479"

COMPATIBLE_HOST = "(i.86|x86_64|powerpc|powerpc64|aarch64|arm).*-linux*"

LIBARGS = "LIB32=${baselib} LIB64=${baselib}"
LIBHUGETLBFS_ARCH = "${TARGET_ARCH}"
LIBHUGETLBFS_ARCH_powerpc = "ppc"
LIBHUGETLBFS_ARCH_powerpc64 = "ppc64"
LIBHUGETLBFS_ARCH_powerpc64le = "ppc64"
EXTRA_OEMAKE = "'ARCH=${LIBHUGETLBFS_ARCH}' 'OPT=${CFLAGS}' 'CC=${CC}' ${LIBARGS} BUILDTYPE=NATIVEONLY V=2"
PARALLEL_MAKE = ""
CFLAGS += "-fexpensive-optimizations -frename-registers -fomit-frame-pointer -g0"

export HUGETLB_LDSCRIPT_PATH="${S}/ldscripts"

TARGET_CC_ARCH += "${LDFLAGS}"

#The CUSTOM_LDSCRIPTS doesn't work with the gold linker
#inherit cpan-base
do_configure() {
    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'ld-is-gold', d)}" ]; then
      sed -i 's/CUSTOM_LDSCRIPTS = yes/CUSTOM_LDSCRIPTS = no/'  Makefile
    fi
}

do_install() {
        oe_runmake PREFIX=${prefix} DESTDIR=${D} \
        install
        rm ${D}/${libdir}/libhugetlbfs.a
        rm ${D}/${libdir}/../bin/hugeadm
        rm ${D}/${libdir}/../bin/hugectl
        rm ${D}/${libdir}/../bin/hugeedit
        rm ${D}/${libdir}/../bin/pagesize
        rm -rf ${D}/${libdir}/../share/libhugetlbfs
        rm -rf ${D}/usr/bin
        rm -rf ${D}/${libdir}/libhugetlbfs
        rm -rf ${D}/usr/share
        rm -rf ${D}/usr/include
}


FILES_${PN} += "${libdir}/*.so"
FILES_${PN}-dev = "${includedir}"
FILES_${PN}-dbg += "${libdir}/libhugetlbfs/tests/obj32/.debug ${libdir}/libhugetlbfs/tests/obj64/.debug"

INSANE_SKIP_${PN} = "dev-so"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
