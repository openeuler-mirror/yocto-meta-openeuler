PV = "2.37.2"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove += " \
           file://avoid_parallel_tests.patch \
           file://Automake-use-EXTRA_LTLIBRARIES-instead-of-noinst_LTL.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend += "file://2.36-login-lastlog-create.patch \
           file://Add-check-to-resolve-uname26-version-test-failed.patch \
           file://SKIPPED-no-root-permissions-test.patch \
           file://backport-su-bash-completion-offer-usernames-rather-than-files.patch \
           file://backport-Fix-memory-leaks-in-the-chcpu.patch \
           file://backport-logger-fix-prio-prefix-doesn-t-use-priority-default.patch \
           file://backport-vipw-flush-stdout-before-getting-answer.patch \
           file://backport-login-Restore-tty-size-after-calling-vhangup.patch \
           file://backport-Forward-value-of-sector_size-instead-of-its-address.patch \
           file://backport-libfdisk-dereference-of-possibly-NULL-gcc-analyzer.patch \
           file://backport-libfdisk-check-calloc-return-gcc-analyzer.patch \
           file://backport-mcookie-fix-infinite-loop-when-use-f.patch \
           file://backport-sfdisk-write-empty-label-also-when-only-ignored-part.patch \
"

SRC_URI[sha256sum] = "6a0764c1aae7fb607ef8a6dd2c0f6c47d5e5fd27aa08820abaad9ec14e28e9d9"
