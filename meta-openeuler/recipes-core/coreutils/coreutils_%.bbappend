# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_9.0.bb
# version in openEuler
PV = "9.4"

# solve lic check failed
LIC_FILES_CHKSUM:remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=b720a8b317035d66c555fc6d89e3674c \
"

# files, patches can't be applied in openeuler or conflict with openeuler
# remove-usr-local-lib-from-m4.patch same as bugfix-remove-usr-local-lib-from-m4.patch
SRC_URI:remove = " \
        file://remove-usr-local-lib-from-m4.patch \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://e8b56ebd536e82b15542a00c888109471936bfda.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0001-disable-test-of-rwlock.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://coreutils-getgrouplist.patch \
        file://bugfix-remove-usr-local-lib-from-m4.patch \
        file://bugfix-dummy_help2man.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch \
        file://backport-config-color-alias-for-ls.patch \
        file://backport-coreutils-df-direct.patch \
        file://backport-coreutils-i18n.patch \
        file://backport-CVE-2024-0684-split-do-not-shrink-hold-buffer.patch \
        file://test-skip-overlay-filesystem-because-of-no-inotify_add_watch.patch \
        file://fix-coredump-if-enable-systemd.patch \
        file://backport-sort-don-t-trust-st_size-on-proc-files.patch \
        file://backport-cat-don-t-trust-st_size-on-proc-files.patch \
        file://backport-dd-don-t-trust-st_size-on-proc-files.patch \
        file://backport-split-don-t-trust-st_size-on-proc-files.patch \
        file://backport-pinky-fix-string-size-calculation.patch \
        file://backport-cksum-consistently-validate-length-attributes.patch \
        file://backport-timeout-fix-race-where-we-might-kill-arbitrary-proce.patch \
        file://backport-timeout-fix-narrow-race-in-failing-to-kill-processes.patch \
        file://backport-maint-basenc-consistently-check-buffer-bounds-when-e.patch \
        file://backport-putenv-Don-t-crash-upon-out-of-memory.patch \
        file://backport-head-off_t-not-uintmax_t-for-file-offset.patch \
        file://backport-shuf-avoid-integer-overflow-on-huge-inputs.patch \
        file://backport-shuf-fix-randomness-bug.patch \
        file://backport-head-fix-overflows-in-elide_tail_bytes_pipe.patch \
        file://backport-numfmt-don-t-require-a-suffix-with-from-iec-i.patch \
        file://backport-sort-fix-debug-buffer-overrun.patch \
        file://backport-tac-avoid-out-of-bounds-access.patch \
        file://backport-yes-avoid-failure-on-CHERI-protected-systems.patch \
        file://backport-cat-fix-plain-cat-bug.patch \
        file://coreutils-9.0-sw.patch \
"

SRC_URI[sha256sum] = "ea613a4cf44612326e917201bbbcdfbd301de21ffc3b59b6e5c07e040b275e52"
