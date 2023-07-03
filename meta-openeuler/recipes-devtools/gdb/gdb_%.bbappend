# main bbfile: yocto-poky/meta/recipes-devtools/gdb/gdb_10.1.bb
# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/gdb/gdb_12.1.bb?id=8d42315c074a97

OPENEULER_SRC_URI_REMOVE = "https git http"

#version in openEuler
PV = "12.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            ${GNU_MIRROR}/gdb/gdb-${PV}.tar.xz \
            "

# files, patches that come from openeuler
SRC_URI += " \
        file://gdb-${PV}.tar.xz \
        file://gdb-6.3-rh-testversion-20041202.patch \
        file://gdb-6.3-gstack-20050411.patch \
        file://gdb-6.3-test-movedir-20050125.patch \
        file://gdb-6.3-threaded-watchpoints2-20050225.patch \
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
        file://gdb-sw22395-constify-target_desc.patch \
        file://0002-set-entry-point-when-text-segment-is-missing.patch \
        file://0003-Add-support-for-readline-8.2.patch \
        "
# These patches can't apply from openEuler
# It may depend on the feature poky not enable, such as --with-rpm, texinfo, etc.
#gdb-6.6-buildid-locate.patch
#gdb-6.6-buildid-locate-solib-missing-ids.patch
#gdb-6.6-buildid-locate-rpm.patch
#gdb-6.6-buildid-locate-rpm-librpm-workaround.patch
#gdb-6.6-buildid-locate-rpm-scl.patch

FILES:${PN}-dev:riscv64 += "/usr/lib64"
