# the main bb file: yocto-poky/meta/recipes-devtools/elfutils/elfutils_0.186.bb
PV = "0.190"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# the path removed in 0.187
SRC_URI:remove = " \
    file://0001-debuginfod-fix-compilation-on-platforms-without-erro.patch \
    file://0001-debuginfod-debuginfod-client.c-use-long-for-cache-ti.patch \
    file://0001-libasm-may-link-with-libbz2-if-found.patch \
"

# patches from 0.191 base recipe that don't apply to openeuler 0.190 source
SRC_URI:remove = " \
    file://0001-debuginfod-Remove-unused-variable.patch \
    file://0001-srcfiles-fix-unused-variable-BUFFER_SIZE.patch \
    file://0001-skip-the-test-when-gcc-not-deployed.patch \
    file://CVE-2025-1352.patch \
    file://CVE-2025-1365.patch \
    file://CVE-2025-1371.patch \
    file://CVE-2025-1372.patch \
    file://CVE-2025-1376.patch \
    file://CVE-2025-1377.patch \
    file://0007-Fix-build-with-gcc-15.patch \
"

# add patches from openeuler
SRC_URI:append = " \
    file://${BP}.tar.bz2 \
    file://Fix-segfault-in-eu-ar-m.patch \
    file://Fix-issue-of-moving-files-by-ar-or-br.patch \
"

SRC_URI[sha256sum] = "df76db71366d1d708365fc7a6c60ca48398f14367eb2b8954efc8897147ad871"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://debuginfod/debuginfod-client.c;endline=27;md5=7eb69ae4d5654e590c840538256a7bfe \
                    "

# 0001-dso-link-change.patch applies with fuzz 2 on openEuler 0.191 tarball
INSANE_SKIP:append = " patch-fuzz"

ASSUME_PROVIDE_PKGS = "elfutils-libelf-devel"
