#main bbfile: yocto-poky/meta/recipes-core/zlib/zlib_1.2.11.bb

#version in openEuler
PV = "1.2.11"

OPENEULER_SRC_URI_REMOVE = "https git http"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        file://CVE-2018-25032.patch \
        file://ldflags-tests.patch \
        "
# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz \
        file://zlib-1.2.5-minizip-fixuncrypt.patch \
        file://fix-undefined-buffer-detected-by-oss-fuzz.patch \
        file://backport-0001-CVE-2018-25032.patch \
        file://backport-0002-CVE-2018-25032.patch \
        file://backport-0001-CVE-2022-37434.patch \
        file://backport-0002-CVE-2022-37434.patch \
        file://backport-Fix-unztell64-in-minizip-to-work-past-4GB.-Dani-l-H-.patch \
        file://backport-Fix-memory-leak-on-error-in-gzlog.c.patch \
        file://backport-Fix-deflateEnd-to-not-report-an-error-at-start-of-ra.patch \
        file://backport-Avoid-an-undefined-behavior-of-memcpy-in-_tr_stored_.patch \
        file://backport-Avoid-an-undefined-behavior-of-memcpy-in-gzappend.patch \
        file://backport-Handle-case-where-inflateSync-used-when-header-never.patch \
        file://backport-Return-an-error-if-the-gzputs-string-length-can-t-fi.patch \
        file://backport-Fix-bug-when-window-full-in-deflate_stored.patch \
        file://backport-Fix-CLEAR_HASH-macro-to-be-usable-as-a-single-statem.patch \
        file://backport-Don-t-bother-computing-check-value-after-successful-.patch \
        file://backport-Avoid-undefined-negation-behavior-if-windowBits-is-I.patch \
        file://backport-Fix-bug-in-block-type-selection-when-Z_FIXED-used.patch \
        file://backport-Fix-inflateBack-to-detect-invalid-input-with-distanc.patch \
        file://backport-Security-and-warning-fixes-for-minizip.-gvollant.patch \
        file://backport-Avoid-adding-empty-gzip-member-after-gzflush-with-Z_FINISH.patch \
        file://backport-Avoid-undefined-behaviors-of-memcpy-in-gzprintf.patch \
        file://backport-Fix-crash-when-gzsetparams-attempted-for-transparent-write.patch \
        file://backport-Remove-use-of-OF-from-contrib-untgz-and-render-it-compilable.patch \
        file://backport-minizip-Fix-being-unable-to-open-empty-zip-file.patch \
        file://backport-Fix-reading-disk-number-start-on-zip64-files-in-minizip.patch \
        file://backport-Fix-logic-error-in-minizip-argument-processing.patch \
        file://backport-Fix-bug-when-gzungetc-is-used-immediately-after-gzopen.patch \
        file://backport-Suppress-MSAN-detections-in-deflate-slide_hash.patch \
        file://backport-Fix-bug-when-using-gzflush-with-a-very-small-buffer.patch \
        file://backport-avoid-uninitialized-and-unused-warnings-in-contrib-minizip.patch \
        file://backport-CVE-2023-45853.patch \
        file://backport-Add-bounds-checking-to-ERR_MSG-macro-used-by-zError.patch \
        file://backport-Fix-bug-in-inflateSync-for-data-held-in-bit-buffer.patch \
        file://backport-Fix-decision-on-the-emission-of-Zip64-end-records-in.patch \
        file://backport-Neutralize-zip-file-traversal-attacks-in-miniunz.patch \
        file://backport-Fix-a-bug-in-ZLIB_DEBUG-compiles-in-check_match.patch \
        file://zlib-Optimize-CRC32.patch \
        file://zlib-1.2.11-SIMD.patch \
        "

# files, patches that come from openeuler for aarch64, there are compile err in 0004-zlib-Optimize-CRC32.patch, not apply
SRC_URI_remove_aarch64 = " \
        file://zlib-Optimize-CRC32.patch \
"

SRC_URI[tarball.md5sum] = "85adef240c5f370b308da8c938951a68"
SRC_URI[tarball.sha256sum] = "4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066"
