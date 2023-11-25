PV = "2.37.2"

# files, patches can't be applied in openeuler or conflict with openeuler
# ptest.patch, patch-fuzz warning
OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_remove += " \
        file://ptest.patch \
        file://avoid_parallel_tests.patch \
        file://Automake-use-EXTRA_LTLIBRARIES-instead-of-noinst_LTL.patch \
        file://CVE-2021-37600.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend += " \
        file://util-linux-${PV}.tar.xz \
        file://2.36-login-lastlog-create.patch \
        file://backport-CVE-2021-3995.patch \
        file://backport-CVE-2021-3996.patch \
        file://realloc-buffer-when-header-size-changed.patch \
        file://fix-size-use-for-stdin.patch \
        file://segmentation-fault-on-invalid-unicode-input-passed-to-s-option.patch \
        file://backport-fix-by-ignoring-EINVAL-on-remount-of-proc.patch \
        file://backport-flush-stdout-before-reading-stdin-and-fix-uninitialized-variable.patch \
        file://backport-fflush-stdout-before-reading-from-stdin.patch \
        file://backport-CVE-2022-0563.patch \
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
        file://backport-fstat-dir-itself.patch \
        file://backport-sfdisk-fix-typo-in-move-data-when-check-partition-size.patch \
        file://backport-sysfs-fallback-for-partitions-not-including-parent-name.patch \
        file://backport-libmount-all-continue-although-proc-is-not-mounted.patch \
        file://backport-libblkid-don-t-mark-cache-as-probed-if-sys-not-available.patch \
        file://backport-lib-path-make-path-use-more-robust-coverity-scan.patch \
        file://backport-Fix-integer-overflow-for-alpha-like-linux.patch \
        file://backport-last-don-t-assume-zero-terminate-strings.patch \
        file://backport-script-fix-passing-args-to-execlp.patch \
        file://backport-scriptlive-fix-argv-0-for-execlp.patch \
        file://backport-losetup-fix-memory-leak-asan.patch \
        file://backport-partx-remove-memory-leak-to-make-scanners-happy-coverity-scan.patch \
        file://backport-lib-path-make-ul_path_read_buffer-more-robust-coverity-scan.patch \
        file://backport-libblkid-make-blkid_free_probe-more-robust.patch \
        file://backport-libmount-fix-possible-memory-leak-in-mnt_optstr_fix_secontext-coverity-scan.patch \
        file://backport-lslocks-fix-maj-min-scanf.patch \
        file://backport-column-don-t-require-column-name-for-JSON.patch \
        file://backport-libblkid-check-fsync-return-code.patch \
        file://backport-lib-strutils-improve-strtoul_or_err-for-negative-numbers.patch \
        file://backport-dmesg-fix-since-and-until.patch \
        file://backport-lib-allow-safe_getenv-to-work-for-non-root-users.patch \
        file://backport-Maybe-there-is-a-little-mistake-in-do_taskset-functi.patch \
        file://backport-loopdev-set-block_size-when-using-LOOP_CONFIGURE.patch \
        file://backport-libblkid-probe-fix-size-and-offset-overflows-fuzzing.patch \
        file://backport-libblkid-bsd-fix-buffer-pointer-use-fuzzing.patch \
        file://backport-libblkid-mac-make-sure-block-size-is-large-enough-fuzzing.patch \
        file://backport-libblkid-hfs-fix-label-use-fuzzing.patch \
        file://backport-libblkid-hfs-fix-make-sure-buffer-is-large-enough.patch \
        file://backport-lslogins-fix-free-invalid-pointer.patch \
        file://backport-lsns-fix-the-memory-leak.patch \
        file://backport-libblkid-src-topology-dm-close-redundant-write-file-.patch \
        file://backport-libblkid-topology-init-variables-for-DM.patch \
        file://backport-lslogins-improve-prefixes-interpretation.patch \
        file://backport-lsblk-fix-endless-loop-if-device-specified-more-than-once.patch \
        file://backport-libblkid-avoid-buffer-overflow-in-ocfs-superblock-parsing.patch \
        file://backport-fsck-Processes-may-kill-other-processes.patch \
        file://backport-fdisk-fix-output-option-parsing.patch \
        file://backport-libblkid-exfat-fix-divide-by-zero-coverity-scan.patch \
        file://backport-llib-pty-session-split-PTY-and-signalfd-setup.patch \
        file://backport-script-fix-use-of-utempter.patch \
        file://backport-logger-always-update-header-when-read-from-stdin.patch \
        file://backport-libblkid-use-checksum-for-jmicron.patch \
        file://backport-libblkid-cleanup-indentation.patch \
        file://backport-libblkid-fix-jmicron-checksum-and-LE-to-CPU.patch \
        file://backport-libblkid-fix-misaligned-address-in-probe_exfat.patch \
        file://backport-ldattach-fix-intro-command-and-pause.patch \
        file://backport-iso9660.h-use-more-correct-function-types.patch \
        file://backport-iso9660.h-avoid-undefined-signed-integer-shift.patch \
        file://backport-ipc_msg_get_limits-always-initialize-memory.patch \
        file://backport-wdctl-mark-flags-field-as-unsigned-long.patch \
        file://backport-login-never-send-signals-to-init.patch \
        file://backport-mkswap-do-not-use-uninitialized-stack-value.patch \
        file://backport-lib-pager-fix-signal-safety-issues.patch \
        file://backport-libblkid-nvidia_raid-verify-superblock-size.patch \
        file://backport-libblkid-nvidia_raid-validate-checksum.patch \
        file://backport-libfdisk-Fix-randomly-generated-GPT-UUID-s.patch \
        file://backport-write-correctly-handle-wide-characters.patch \
        file://backport-wall-convert-homebrew-buffering-to-open_memstream.patch \
        file://backport-wall-use-fputs_careful.patch \
        file://backport-hexdump-parse-handle-truncated-format-pattern.patch \
        file://backport-libblkid-copy-BLKID_PARTS_FORCE_GPT-to-whole-disk-pr.patch \
        file://backport-lscpu-fix-p-output-all-caches-delimiter.patch \
        file://backport-add-return-in-supam_conv-function.patch \
        file://backport-wrap-return-in-else-directive-to-avoid-dead-code.patch \
        file://backport-sulogin-ignore-none-existing-console-devices.patch \
        file://backport-sulogin-fix-KDGKBMODE-ifdef.patch \
        file://backport-unshare-Move-implementation-of-keep-caps-option-to-l.patch \
        file://backport-lib-caputils-fix-integer-handling-issues-coverity-sc.patch \
        file://backport-libblkid-jfs-avoid-undefined-shift.patch \
        file://backport-cfdisk-add-hint-about-labels-for-bootable-flag.patch \
        file://backport-logger-initialize-socket-credentials-contol-union.patch \
        file://backport-column-fix-buffer-overflow-when-l-specified.patch \
        file://backport-column-fix-greedy-mode-on-l.patch \
        file://backport-column-fix-memory-leak.patch \
        file://backport-column-fix-l.patch \
        file://Add-check-to-resolve-uname26-version-test-failed.patch \
        file://SKIPPED-no-root-permissions-test.patch \
"

SRC_URI[sha256sum] = "6a0764c1aae7fb607ef8a6dd2c0f6c47d5e5fd27aa08820abaad9ec14e28e9d9"
