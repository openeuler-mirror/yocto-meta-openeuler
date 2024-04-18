
# version in openEuler
PV = "14.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# files, patches that come from openeuler
SRC_URI:prepend = "file://gdb-${PV}.tar.xz \
           "

# patches no longer needed for version 14.1
SRC_URI:remove = " \
        file://0001-make-man-install-relative-to-DESTDIR.patch \
        file://0002-mips-linux-nat-Define-_ABIO32-if-not-defined.patch \
        file://0003-ppc-ptrace-Define-pt_regs-uapi_pt_regs-on-GLIBC-syst.patch \
        file://0005-Dont-disable-libreadline.a-when-using-disable-static.patch \
        file://0006-use-asm-sgidefs.h.patch \
        file://0007-Change-order-of-CFLAGS.patch \
        file://0008-resolve-restrict-keyword-conflict.patch \
        file://0009-Fix-invalid-sigprocmask-call.patch \
        file://0010-gdbserver-ctrl-c-handling.patch \
"

# patches from poky for version 14.1
SRC_URI:append = " \
        file://0001-mips-linux-nat-Define-_ABIO32-if-not-defined.patch \
        file://0002-ppc-ptrace-Define-pt_regs-uapi_pt_regs-on-GLIBC-syst.patch \
        file://0003-Dont-disable-libreadline.a-when-using-disable-static.patch \
        file://0004-use-asm-sgidefs.h.patch \
        file://0005-Change-order-of-CFLAGS.patch \
        file://0006-resolve-restrict-keyword-conflict.patch \
        file://0007-Fix-invalid-sigprocmask-call.patch \
        file://0008-Define-alignof-using-_Alignof-when-using-C11-or-newe.patch \
"

# patches that come from openeuler
SRC_URI:append = " \
        file://gdb-6.3-rh-testversion-20041202.patch \
        file://gdb-6.3-gstack-20050411.patch \
        file://gdb-6.5-bz185337-resolve-tls-without-debuginfo-v2.patch \
        file://gdb-6.5-BEA-testsuite.patch \
        file://gdb-6.5-bz218379-ppc-solib-trampoline-test.patch \
        file://gdb-6.6-bz229517-gcore-without-terminal.patch \
        file://gdb-6.6-testsuite-timeouts.patch \
        file://gdb-6.6-bz237572-ppc-atomic-sequence-test.patch \
        file://gdb-6.3-attach-see-vdso-test.patch \
        file://gdb-6.5-bz243845-stale-testing-zombie-test.patch \
        file://gdb-6.7-ppc-clobbered-registers-O2-test.patch \
        file://gdb-6.5-gcore-buffer-limit-test.patch \
        file://gdb-6.3-mapping-zero-inode-test.patch \
        file://gdb-6.5-section-num-fixup-test.patch \
        file://gdb-6.8-bz466901-backtrace-full-prelinked.patch \
        file://gdb-simultaneous-step-resume-breakpoint-test.patch \
        file://gdb-core-open-vdso-warning.patch \
        file://gdb-archer-next-over-throw-cxx-exec.patch \
        file://gdb-test-bt-cfi-without-die.patch \
        file://gdb-bz634108-solib_address.patch \
        file://gdb-test-dw2-aranges.patch \
        file://gdb-glibc-strstr-workaround.patch \
        file://gdb-rhbz-818343-set-solib-absolute-prefix-testcase.patch \
        file://gdb-rhbz947564-findvar-assertion-frame-failed-testcase.patch \
        file://gdb-rhbz1007614-memleak-infpy_read_memory-test.patch \
        file://gdb-6.6-buildid-locate-misleading-warning-missing-debuginfo-rhbz981154.patch \
        file://gdb-rhbz1156192-recursive-dlopen-test.patch \
        file://gdb-rhbz1149205-catch-syscall-after-fork-test.patch \
        file://gdb-rhbz1084404-ppc64-s390x-wrong-prologue-skip-O2-g-3of3.patch \
        file://gdb-rhbz1261564-aarch64-hw-watchpoint-test.patch \
        file://gdb-container-rh-pkg.patch \
        file://gdb-linux_perf-bundle.patch \
        file://gdb-add-index.patch \
        file://gdb-rhbz2232086-refactor-selftest-support.patch \
        file://gdb-rhbz-2232086-reduce-size-of-gdb-index.patch \
        file://gdb-rhbz-2232086-cpp-ify-mapped-symtab.patch \
        file://gdb-rhbz-2232086-generate-gdb-index-consistently.patch \
        file://gdb-rhbz-2232086-generate-dwarf-5-index-consistently.patch \
        file://gdb-rhbz2250652-gdbpy_gil.patch \
        file://gdb-rhbz2250652-avoid-PyOS_ReadlineTState.patch \
        file://gdb-rhbz2257562-cp-namespace-null-ptr-check.patch \
        file://gdb-ftbs-swapped-calloc-args.patch \
        file://0001-set-entry-point-when-text-segment-is-missing.patch \
        "

# These patches can't apply from openEuler
# If apply the following patches, the build will fail at do_compile phase,
# indicating that "make: Nothing to be done for 'all'".
# It may depend on the feature poky not enable, such as --with-rpm, texinfo, etc.
# gdb-6.6-buildid-locate.patch
# gdb-6.6-buildid-locate-solib-missing-ids.patch
# gdb-6.6-buildid-locate-rpm.patch
# gdb-6.6-buildid-locate-rpm-librpm-workaround.patch
# gdb-fedora-libncursesw.patch

# fix bug: in OEE, the basic library path for riscv64 is lib64/lp64d.
# During building gdb, this directory will be deleted, but the empty
# lib64/ directory is not deleted, resulting in packaging issues.
# So, here remove it.
do_install:append:riscv64() {
	rm -rf ${D}/usr/lib64
}

DEPENDS += "mpfr"
