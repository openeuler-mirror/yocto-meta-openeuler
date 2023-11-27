# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_8.32.bb

# version in openEuler
PV = "9.0"

# solve lic check failed
LIC_FILES_CHKSUM_remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=b7d80abf5b279320fb0e4b1007ed108b \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/coreutils/${BP}.tar.xz \
        file://remove-usr-local-lib-from-m4.patch \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://disable-ls-output-quoting.patch \
        file://0001-ls-restore-8.31-behavior-on-removed-directories.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://${BP}.tar.xz \
        file://0001-disable-test-of-rwlock.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://coreutils-getgrouplist.patch \
        file://bugfix-remove-usr-local-lib-from-m4.patch \
        file://bugfix-dummy_help2man.patch \
        file://bugfix-selinux-flask.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch  \
        file://backport-chmod-fix-exit-status-when-ignoring-symlinks.patch \
        file://backport-timeout-ensure-foreground-k-exits-with-status-137.patch \
        file://backport-config-color-alias-for-ls.patch \
        file://backport-coreutils-i18n.patch \
        file://backport-sort-fix-sort-g-infloop-again.patch \
        file://backport-tests-sort-NaN-infloop-augment-testing-for-recent-fi.patch \
        file://backport-comm-fix-NUL-output-delimiter-with-total.patch \
        file://backport-stty-validate-ispeed-and-ospeed-arguments.patch \
        file://backport-fts-fix-race-mishandling-of-fstatat-failure.patch \
        file://backport-stty-fix-off-by-one-column-wrapping-on-output.patch \
        file://backport-copy-copy_file_range-handle-ENOENT-for-CIFS.patch \
        file://backport-tail-fix-support-for-F-with-non-seekable-files.patch \
        file://backport-fts-fail-gracefully-when-out-of-memory.patch \
        file://backport-pr-fix-infinite-loop-when-double-spacing.patch \
        file://backport-wc-ensure-we-update-file-offset.patch \
        file://backport-who-fix-only-theoretical-overflow.patch \
        file://backport-tac-handle-short-reads-on-input.patch \
        file://backport-setenv-Don-t-crash-if-malloc-returns-NULL.patch \
        file://backport-who-don-t-crash-if-clock-gyrates.patch \
        file://backport-doc-od-strings-clarify-operation.patch \
        file://backport-wc-port-to-kernels-that-disable-XSAVE-YMM.patch \
"  
