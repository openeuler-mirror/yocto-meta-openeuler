# main bbfile: yocto-poky/meta/recipes-extended/bash/bash_5.1.16.bb

# bash version in openeuler
PV = "5.2.15"

# These patches have been merged in this version
SRC_URI:remove = " file://CVE-2022-3715.patch \
           file://execute_cmd.patch \
           file://use_aclocal.patch \
           file://makerace.patch \
           file://makerace2.patch \
           "

# patches in openeuler
SRC_URI:prepend = " \
           file://${BP}.tar.gz;name=tarball \
           file://bash-2.05a-interpreter.patch \
           file://bash-2.05b-pgrp_sync.patch \
           file://bash-4.0-nobits.patch \
           file://bash-4.2-coverity.patch \
           file://bash-4.3-noecho.patch \
           file://bash-4.3-memleak-lc_all.patch \
           file://bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://enable-dot-logout-and-source-bashrc-through-ssh.patch \
           file://cd-alias.patch \
           file://bash-5.1-sw.patch \
           file://backport-fix-for-nofork-comsub-command-printing-fix-for-crash.patch \
           file://backport-fix-small-memleak-in-globbing.patch \
           file://backport-fix-for-leak-when-completing-command-word-with-glob-.patch \
           file://backport-fix-for-E-transformation-fixes-for-failures-in-arith.patch \
           file://backport-changes-for-quoting-special-and-multibyte-characters.patch \
           file://backport-fixes-for-LINENO-in-multi-line-simple-commands-print.patch \
           file://backport-changes-to-SIGINT-handler-while-waiting-for-a-child-.patch \
           file://backport-renamed-several-functions-beginning-with-legal_-chan.patch \
           file://backport-fix-for-cd-when-curent-directory-doesn-t-exist-fix-w.patch \
           file://Fix-for-a-crash-if-one-of-the-expressions-in-an-arit.patch \
           file://backport-posix-change-for-undoing-redirections-after-failed-e.patch \
           file://backport-fix-issue-with-failed-history-expansion-changing-the.patch \
           file://backport-revert-change-that-suppressed-array-subscript-expans.patch \
           file://backport-documentation-updates-for-arithmetic-expansion-and-a.patch \
           file://backport-fix-typo-in-readline-custom-LS_COLORS-extension-fix-.patch \
           file://backport-fourth-set-of-ANSI-C-changes-size_t-rest-globskipdot.patch \
           file://backport-documentation-updates-fix-for-null-commands-with-red.patch \
           file://backport-fix-for-readline-redisplay-issue-in-C-locale-fix-for.patch \
           file://backport-fixes-for-glibc-time-gettimeofday-issue-fix-issue-wi.patch \
           file://backport-Bash-5.2-patch-17-fix-for-optimizing-forks-when-usin.patch \
           file://backport-Bash-5.2-patch-19-fix-case-where-background-job-set-.patch \
           file://backport-Bash-5.2-patch-20-allow-time-reserved-word-as-first-.patch \
           file://backport-Bash-5.2-patch-21-fix-for-expanding-command-substitu.patch \
           file://backport-Bash-5.2-patch-22-fix-readline-attempting-to-zero-ou.patch \
           file://backport-Bash-5.2-patch-23-fix-local-from-overwriting-saved-s.patch \
           file://backport-Bash-5.2-patch-24-fix-problem-with-tilde-expansion-o.patch \
           file://backport-Bash-5.2-patch-25-fix-problem-with-subshells-termina.patch \
           file://backport-Bash-5.2-patch-27-fix-autoconf-test-for-strtoimax.patch \
           file://backport-Bash-5.2-patch-28-fix-terminal-pgrp-handling-in-DEBU.patch \
           file://backport-Bash-5.2-patch-29-fix-for-error-recovery-when-parsin.patch \
           file://backport-Bash-5.2-patch-30-fix-bug-with-marking-jobs-terminat.patch \
           file://backport-Bash-5.2-patch-31-fix-memory-leak-in-optimized-file-.patch \
           file://backport-Bash-5.2-patch-32-fix-printing-coprocs-when-the-copr.patch \
           file://backport-Bash-5.2-patch-34-fix-for-parsing-compound-assignmen.patch \
           file://backport-Bash-5.2-patch-36-fix-for-reading-partial-invalid-mu.patch \
           file://backport-fix-minor-errors-uncovered-by-address-sanitizer-work.patch \
           file://backport-avoid-storing-extra-copy-of-function-bodies-fix-some.patch \
           file://only-scripts-verified-by-execveat-are-allowed-to-run.patch \
"

SRC_URI[tarball.sha256sum] = "13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"

# When busybox is used as init manager (mdev-busybox), busybox/ash outperforms
# bash in UnixBench, so let busybox own /bin/sh in that case.
# When busybox is not present (e.g. systemd mode), bash must provide /bin/sh
# because nothing else does — removing "sh" from ALTERNATIVE would leave
# /bin/sh missing and break do_rootfs RPM dependency resolution.
ALTERNATIVE:${PN}:remove = "${@bb.utils.contains('INIT_MANAGER', 'mdev-busybox', 'sh', '', d)}"

ASSUME_PROVIDE_PKGS = "bash"
