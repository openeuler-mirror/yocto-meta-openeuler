#main bbfile: yocto-poky/meta/recipes-core/zlib/zlib_1.2.11.bb

#version in openEuler
PV = "1.2.13"

# files, patches that come from openeuler
SRC_URI = " \
        file://${BP}.tar.xz \
        file://backport-zlib-1.2.5-minizip-fixuncrypt.patch \
        file://backport-CVE-2023-45853.patch \
        file://backport-Fix-crash-when-gzsetparams-attempted-for-transparent-write.patch \
        file://backport-Remove-use-of-OF-from-contrib-untgz-and-render-it-compilable.patch \
        file://backport-minizip-Fix-being-unable-to-open-empty-zip-file.patch \
        file://backport-Fix-reading-disk-number-start-on-zip64-files-in-minizip.patch \
        file://backport-Fix-logic-error-in-minizip-argument-processing.patch \
        file://backport-Fix-bug-when-gzungetc-is-used-immediately-after-gzopen.patch \
        file://backport-Suppress-MSAN-detections-in-deflate-slide_hash.patch \
        file://backport-Fix-bug-when-using-gzflush-with-a-very-small-buffer.patch \
        file://backport-avoid-uninitialized-and-unused-warnings-in-contrib-minizip.patch \
        file://backport-Add-bounds-checking-to-ERR_MSG-macro-used-by-zError.patch \
        file://backport-Fix-bug-in-inflateSync-for-data-held-in-bit-buffer.patch \
        file://backport-Fix-decision-on-the-emission-of-Zip64-end-records-in.patch \
        file://backport-Neutralize-zip-file-traversal-attacks-in-miniunz.patch \
        file://backport-Fix-a-bug-in-ZLIB_DEBUG-compiles-in-check_match.patch \
        file://backport-CVE-2026-27171.patch \
        "

# files, patches that come from openeuler for aarch64, there are compile err in 0004-zlib-Optimize-CRC32.patch, not apply
SRC_URI:append:aarch64 = " \
        file://zlib-1.2.11-SIMD.patch \
        "

SRC_URI[md5sum] = "5e6af153311327e516690d300527ec9e"
SRC_URI[sha256sum] = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"

B = "${WORKDIR}/build"

do_configure() {
	LDCONFIG=true ${S}/configure --prefix=${prefix} --shared --libdir=${libdir} --uname=GNU
}
do_configure[cleandirs] += "${B}"

ASSUME_PROVIDE_PKGS = "zlib"
