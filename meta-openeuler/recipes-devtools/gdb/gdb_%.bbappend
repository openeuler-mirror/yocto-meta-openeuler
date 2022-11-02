# main bbfile: yocto-poky/meta/recipes-devtools/gdb/gdb_10.1.bb

#version in openEuler
PV = "11.1"

DEPENDS_append += "gmp"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            ${GNU_MIRROR}/gdb/gdb-${PV}.tar.xz \
            file://0001-make-man-install-relative-to-DESTDIR.patch \
            file://0002-mips-linux-nat-Define-_ABIO32-if-not-defined.patch \
            file://0003-ppc-ptrace-Define-pt_regs-uapi_pt_regs-on-GLIBC-syst.patch \
            file://0004-Add-support-for-Renesas-SH-sh4-architecture.patch \
            file://0005-Dont-disable-libreadline.a-when-using-disable-static.patch \
            file://0006-use-asm-sgidefs.h.patch \
            file://0008-Change-order-of-CFLAGS.patch \
            file://0009-resolve-restrict-keyword-conflict.patch \
            file://0010-Fix-invalid-sigprocmask-call.patch \
            file://0011-gdbserver-ctrl-c-handling.patch \
            "

# files, patches that come from openeuler
SRC_URI += " \
        file://gdb-${PV}.tar.xz \
        file://gdb-6.3-rh-testversion-20041202.patch \
        file://gdb-6.3-gstack-20050411.patch \
        file://gdb-6.3-test-dtorfix-20050121.patch \
        file://gdb-6.3-test-movedir-20050125.patch \
        file://gdb-6.3-threaded-watchpoints2-20050225.patch \
        file://gdb-6.3-inferior-notification-20050721.patch \
        file://gdb-6.3-inheritancetest-20050726.patch \
        file://gdb-6.5-bz185337-resolve-tls-without-debuginfo-v2.patch \
        file://gdb-6.5-sharedlibrary-path.patch \
        file://gdb-6.5-BEA-testsuite.patch \
        file://gdb-6.5-last-address-space-byte-test.patch \
        file://gdb-6.5-readline-long-line-crash-test.patch \
        file://gdb-6.5-bz218379-ppc-solib-trampoline-test.patch \
        file://gdb-6.5-bz109921-DW_AT_decl_file-test.patch \
        file://gdb-6.3-bz140532-ppc-unwinding-test.patch \
        file://gdb-6.3-bz202689-exec-from-pthread-test.patch \
        file://gdb-6.6-bz230000-power6-disassembly-test.patch \
        file://gdb-6.6-bz229517-gcore-without-terminal.patch \
        file://gdb-6.6-testsuite-timeouts.patch \
        file://gdb-6.6-bz237572-ppc-atomic-sequence-test.patch \
        file://gdb-6.3-attach-see-vdso-test.patch \
        file://gdb-6.5-bz243845-stale-testing-zombie-test.patch \
        file://gdb-6.7-charsign-test.patch \
        file://gdb-6.7-ppc-clobbered-registers-O2-test.patch \
        file://gdb-6.7-testsuite-stable-results.patch \
        file://gdb-6.5-ia64-libunwind-leak-test.patch \
        file://gdb-6.5-missed-trap-on-step-test.patch \
        file://gdb-6.5-gcore-buffer-limit-test.patch \
        file://gdb-6.3-mapping-zero-inode-test.patch \
        file://gdb-6.3-focus-cmd-prev-test.patch \
        file://gdb-6.8-bz442765-threaded-exec-test.patch \
        file://gdb-6.5-section-num-fixup-test.patch \
        file://gdb-6.8-bz466901-backtrace-full-prelinked.patch \
        file://gdb-simultaneous-step-resume-breakpoint-test.patch \
        file://gdb-core-open-vdso-warning.patch \
        file://gdb-ccache-workaround.patch \
        file://gdb-lineno-makeup-test.patch \
        file://gdb-ppc-power7-test.patch \
        file://gdb-archer-next-over-throw-cxx-exec.patch \
        file://gdb-bz601887-dwarf4-rh-test.patch \
        file://gdb-test-bt-cfi-without-die.patch \
        file://gdb-bz634108-solib_address.patch \
        file://gdb-test-pid0-core.patch \
        file://gdb-test-dw2-aranges.patch \
        file://gdb-test-expr-cumulative-archer.patch \
        file://gdb-physname-pr11734-test.patch \
        file://gdb-physname-pr12273-test.patch \
        file://gdb-test-ivy-bridge.patch \
        file://gdb-runtest-pie-override.patch \
        file://gdb-glibc-strstr-workaround.patch \
        file://gdb-rhel5.9-testcase-xlf-var-inside-mod.patch \
        file://gdb-rhbz-818343-set-solib-absolute-prefix-testcase.patch \
        file://gdb-rhbz947564-findvar-assertion-frame-failed-testcase.patch \
        file://gdb-rhbz1007614-memleak-infpy_read_memory-test.patch \
        file://gdb-6.6-buildid-locate-misleading-warning-missing-debuginfo-rhbz981154.patch \
        file://gdb-fortran-frame-string.patch \
        file://gdb-rhbz1156192-recursive-dlopen-test.patch \
        file://gdb-rhbz1149205-catch-syscall-after-fork-test.patch \
        file://gdb-rhbz1186476-internal-error-unqualified-name-re-set-test.patch \
        file://gdb-rhbz1350436-type-printers-error.patch \
        file://gdb-rhbz1084404-ppc64-s390x-wrong-prologue-skip-O2-g-3of3.patch \
        file://gdb-fedora-libncursesw.patch \
        file://gdb-opcodes-clflushopt-test.patch \
        file://gdb-rhbz1261564-aarch64-hw-watchpoint-test.patch \
        file://gdb-container-rh-pkg.patch \
        file://gdb-rhbz1325795-framefilters-test.patch \
        file://gdb-linux_perf-bundle.patch \
        file://gdb-libexec-add-index.patch \
        file://gdb-rhbz1398387-tab-crash-test.patch \
        file://gdb-rhbz1553104-s390x-arch12-test.patch \
        file://gdb-rhbz1976887-field-location-kind.patch \
        file://gdb-test-for-rhbz1976887.patch \
        file://gdb-rhbz2012976-paper-over-fortran-lex-problems.patch \
        file://gdb-rhbz2022177-dprintf-1.patch \
        file://gdb-rhbz2022177-dprintf-2.patch \
        file://0001-Make-c-exp.y-work-with-Bison-3.8.patch \
        "
# These patches can't apply from openEuler
# It may depend on the feature poky not enable, such as --with-rpm, texinfo, etc.
#gdb-6.6-buildid-locate.patch
#gdb-6.6-buildid-locate-solib-missing-ids.patch
#gdb-6.6-buildid-locate-rpm.patch
#gdb-6.6-buildid-locate-rpm-librpm-workaround.patch
#gdb-6.6-buildid-locate-rpm-scl.patch
#gdb-rhbz-853071-update-manpages.patch

EXTRA_OECONF_append += " \
        --with-libgmp-prefix=${STAGING_EXECPREFIXDIR} \
        "

FILES_${PN}-dev_riscv64 += "/usr/lib64"
