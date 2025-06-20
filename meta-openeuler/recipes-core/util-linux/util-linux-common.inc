PV = "2.39.1"

# files, patches can't be applied in openeuler or conflict with openeuler
# ptest.patch, patch-fuzz warning
SRC_URI:remove = " \
        file://ptest.patch \
        file://avoid_parallel_tests.patch \
        file://Automake-use-EXTRA_LTLIBRARIES-instead-of-noinst_LTL.patch \
        file://CVE-2021-37600.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://util-linux-${PV}.tar.xz \
        file://2.36-login-lastlog-create.patch \
        file://backport-unshare-Move-implementation-of-keep-caps-option-to-l.patch \
        file://backport-lib-caputils-fix-integer-handling-issues-coverity-sc.patch \
        file://backport-fadvise-test-dynamically-calculate-expected-test-val.patch \
        file://backport-fadvise-tests-factor-out-calls-to-fincore.patch \
        file://backport-fadvise-test-don-t-compare-fincore-page-counts.patch \
        file://backport-fadvise-test-test-with-64k-blocks.patch \
        file://backport-tests-lsfd-mkfds-alter-the-L4-ports-for-avo.patch \
        file://SKIPPED-no-root-permissions-test.patch \
        file://backport-CVE-2024-28085.patch \
        file://backport-tests-test_mkfds-netlink-pass-a-correct-file-descrip.patch \
        file://backport-tests-functions.sh-add-a-helper-funcion-making-a-dev.patch \
        file://backport-tests-lsfd-don-t-refer-on-the-line-follwoing-the-use.patch \
        file://backport-lsfd-fix-memory-leak-in-append_filter_expr.patch \
        file://backport-libmount-use-some-MS_-flags-as-superblock-flags.patch \
        file://backport-libmount-Fix-regression-when-mounting-with-atime.patch \
        file://backport-libmount-ifdef-statx-call.patch \
        file://backport-libmount-improve-mnt_table_next_child_fs.patch \
        file://backport-libmount-make-sure-option-is-used-as-string.patch \
        file://backport-libmount-fix-possible-memory-leak.patch \
        file://backport-libmount-Fix-atime-remount-for-new-API.patch \
        file://backport-sys-utils-setpriv-fix-potential-memory-leak.patch \
        file://backport-sys-utils-save_adjtime-fix-memory-leak.patch \
        file://backport-wall-fix-possible-memory-leak.patch \
        file://backport-suL-fix-use-after-free-on-error.patch \
        file://backport-cfdisk-add-hint-about-labels-for-bootable-flag.patch \
        file://backport-column-fix-memory-leak.patch \
        file://backport-column-fix-l.patch \
        file://backport-scriptreplay-support-ctrl-s-and-ctrl-g.patch \
        file://backport-login-use-correct-terminal-fd-during-setup.patch \
        file://backport-login-prevent-undefined-ioctl-and-tcsetattr-calls.patch \
        file://backport-libblkid-avoid-memory-leak-of-cachefile-path.patch \
        file://backport-more-avoid-out-of-bound-access.patch \
        file://backport-lslogins-fix-realloc-loop-allocation-size.patch \
        file://backport-ldattach-don-t-call-exit-from-signal-handler.patch \
        file://backport-libblkid-ntfs-validate-that-sector_size-is-a-power-o.patch \
        file://backport-blkid-fix-call-to-err_exclusive_options.patch \
        file://backport-libblkid-reset-errno-before-calling-probefuncs.patch \
        file://backport-lib-path-fix-possible-out-of-boundary-access.patch \
        file://backport-libmount-fix-possible-NULL-dereference-coverity-scan.patch \
        file://backport-libsmartcols-drop-spourious-newline-in-between-strea.patch \
        file://backport-libsmartcols-flush-correct-stream.patch \
        file://backport-libsmartcols-only-recognize-closed-object-as-final-e.patch \
        file://backport-cal-avoid-out-of-bound-write.patch \
        file://backport-libfdisk-sun-properly-initialize-partition-data.patch \
        file://backport-include-c.h-add-helpers-for-unaligned-structure-acce.patch \
        file://backport-libblkid-probe-read-data-in-chunks.patch \
        file://backport-libblkid-avoid-aligning-out-of-probing-area.patch \
        file://backport-libblkid-drbd-validate-zero-padding.patch \
        file://backport-more-exit-if-POLLERR-and-POLLHUP-on-stdin-is-receive.patch \
        file://backport-libblkid-hfsplus-reduce-false-positive.patch \
        file://backport-wall-fix-calloc-cal-Werror-calloc-transposed-args.patch \
        file://backport-libblkid-drbd-reduce-false-positive.patch \
        file://backport-lib-cpuset-exit-early-from-cpulist_parse.patch \
        file://backport-sys-utils-lscpu-Unblock-SIGSEGV-before-vmware_bdoor.patch \
        file://backport-libblkid-Check-offset-in-LUKS2-header.patch \
        file://backport-more-fix-poll-use.patch \
        file://backport-lscpu-don-t-use-NULL-sharedmap.patch \
        file://backport-hexdump-check-blocksize-when-display-data.patch \
        file://backport-lslocks-fix-buffer-overflow.patch \
        file://backport-last-avoid-out-of-bounds-array-access.patch \
        file://backport-lsipc-fix-semaphore-USED-counter.patch \
        file://backport-fsck.minix-fix-possible-overrun.patch \
        file://backport-wall-make-sure-unsigned-variable-not-underflow.patch \
        file://backport-Fix-ul_path_read_buffer.patch \
        file://backport-libblkid-constify-cached-disk-data.patch \
        file://backport-jsonwrt-add-ul_jsonwrt_flush.patch \
        file://backport-dmesg-print-object-closing-brace-while-waiting-for-n.patch \
        file://backport-sys-utils-hwclock-rtc-fix-pointer-usage.patch \
        file://backport-rev-Check-for-wchar-conversion-errors.patch \
        file://backport-libsmartcols-fix-column-reduction.patch \
        file://backport-libmount-cleanup-fake-mode.patch \
        file://backport-lsmem-make-lsmem-to-check-for-the-nodes-more-robust.patch \
        file://backport-cfdisk-fix-possible-integer-overflow-coverity-scan.patch \
        file://backport-more-make-sure-we-have-data-on-stderr.patch \
        file://backport-libblkid-apfs-validate-checksums.patch \
        file://backport-lscpu-add-riscv-cputype-support.patch \
        file://backport-libblkid-fix-potential-memory-leaks.patch \
        file://backport-sys-utils-fix-add-NULL-check-for-mnt_fs_get_target-r.patch \
        file://backport-sulogin-fix-POSIX-locale-use.patch \
        file://backport-setpriv.c-fix-memory-leak-in-parse_groups-function.patch \
        file://backport-whereis-avoid-accessing-uninitialized-memory.patch \
        file://backport-dmesg-fix-notime-use.patch \
        file://sfdisk-fix-crash-casued-by-out-of-bounds-access.patch \
        file://mount-fix-use-option-owner-mount-failed.patch \
        file://mkfs.bfs-fix-memory-leaks-and-weak-code.patch \
"

# unapplicable OE patches: 
# file://util-linux-Add-sw64-architecture.patch
# file://add-new-gmo-file.patch

LICENSE = "GPL-2.0-or-later & LGPL-2.1-or-later & BSD-2-Clause & BSD-3-Clause & BSD-4-Clause"
LIC_FILES_CHKSUM = "file://README.licensing;md5=12ae7768a65ec8f2e44d930df9cb43fa \
                    file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://Documentation/licenses/COPYING.GPL-2.0-or-later;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://Documentation/licenses/COPYING.LGPL-2.1-or-later;md5=4fbd65380cdd255951079008b364516c \
                    file://Documentation/licenses/COPYING.BSD-3-Clause;md5=58dcd8452651fc8b07d1f65ce07ca8af \
                    file://Documentation/licenses/COPYING.BSD-4-Clause-UC;md5=263860f8968d8bafa5392cab74285262 \
                    file://libuuid/COPYING;md5=6d2cafc999feb2c2de84d4d24b23290c \
                    file://libmount/COPYING;md5=7c7e39fb7d70ffe5d693a643e29987c2 \
                    file://libblkid/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
                    file://libfdisk/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
                    file://libsmartcols/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
                    "

SRC_URI[sha256sum] = "890ae8ff810247bd19e274df76e8371d202cda01ad277681b0ea88eeaa00286b"
