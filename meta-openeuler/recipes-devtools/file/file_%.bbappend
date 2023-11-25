# bbfile: yocto-poky/meta/recipes-devtools/file/file_5.39.bb
OPENEULER_SRC_URI_REMOVE = "git"

PV = "5.41"

SRC_URI_remove = "\
        file://0001-src-compress.c-correct-header-define-for-xz-lzma.patch \
        file://0001-Fix-close_on_exec-multithreaded-decompression-issue.patch \
"

SRC_URI_prepend = "file://${BP}.tar.gz \
        file://0001-file-localmagic.patch \
        file://0002-fix-typos-fxlb.patch \
        file://CVE-2022-48554.patch \
"
S = "${WORKDIR}/${BP}"
SRC_URI[sha256sum] = "13e532c7b364f7d57e23dfeea3147103150cb90593a57af86c10e4f6e411603f"
