PV = "1.5.0"

SRC_URI = " \
        https://github.com/facebook/zstd/archive/v${PV}.tar.gz#/${BPN}-${PV}.tar.gz \
        file://backport-zstd-1.5.0-patch-1-set-mtime-on-output-files.patch  \
        file://backport-zstd-1.5.0-patch-2-add-tests-set-mtime-on-output-files.patch \
        file://backport-zstd-1.5.0-patch-3-remove-invalid-test.patch \
        file://backport-zstd-1.5.0-patch-4-limit-train-samples.patch \
        file://patch-5-add-test-case-survive-a-list-of-files-which-long-file-name-length.patch \
        file://backport-zstd-1.5.0-patch-6-fix-a-determinism-bug-with-the-DUBT.patch \
        file://patch-7-add-test-case.patch \
        file://patch-8-fix-extra-newline-gets-printes-out-when-compressing-multiple-files.patch \
        file://patch-9-add-test-c-result-print.patch \
        file://backport-zstd-1.5.0-patch-10-fix-entropy-repeat-mode-bug.patch \
        file://backport-zstd-1.5.0-patch-11-Fix-progress-flag-to-properly-control-progress-display-and-default.patch \
        file://backport-zstd-1.5.0-patch-12-Z_PREFIX-zError-function.patch \
        file://backport-zstd-1.5.0-patch-13-fix-Add-missing-bounds-checks-during-compression.patch \
        file://patch-14-fix-pooltests-result-print.patch \
           file://0001-Makefile-sort-all-wildcard-file-list-expansions.patch \
           "

S = "${WORKDIR}/${BP}"
SRC_URI[sha256sum] = "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867"

do_compile_append () {
    oe_runmake ${PACKAGECONFIG_CONFARGS} ZSTD_LEGACY_SUPPORT=${ZSTD_LEGACY_SUPPORT} -C contrib/pzstd
}

do_install_append () {
    oe_runmake install 'DESTDIR=${D}' PREFIX=${prefix} -C contrib/pzstd
}
