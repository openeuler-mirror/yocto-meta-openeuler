FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "3.11.6"
PYTHON_MAJMIN = "3.11"

# Ensure the overridden check_build_completeness.py is executable before do_install
do_install:prepend:class-native() {
    chmod +x "${WORKDIR}/check_build_completeness.py"
}

# SP4 backport patches may fuzz against 3.11.6 sources

# shebang-size check can fail when sstate is reused across different build paths
INSANE_SKIP:append:class-native = " shebang-size"

# libedit in sysroot defines rl_compdisp_func_t but not VFunction;
# force readline.c to use the rl_compdisp_func_t path
CACHED_CONFIGUREVARS:append = " CFLAGS_NODIST='${CFLAGS} -D_RL_FUNCTION_TYPEDEF'"

SRC_URI:prepend = "file://Python-${PV}.tar.xz \
"

# remove conflicting patch
SRC_URI:remove = "file://0001-Skip-failing-tests-due-to-load-variability-on-YP-AB.patch \
        file://0001-Makefile.pre-use-qemu-wrapper-when-gathering-profile.patch \
        file://0001-python3-use-cc_basename-to-replace-CC-for-checking-c.patch \
        file://0020-configure.ac-setup.py-do-not-add-a-curses-include-pa.patch \
        file://0001-test_ctypes.test_find-skip-without-tools-sdk.patch \
        file://makerace.patch \
        file://0001-Avoid-shebang-overflow-on-python-config.py.patch \
        file://0001-test_readline-skip-limited-history-test.patch \
        file://CVE-2025-6075.patch \
        file://CVE-2025-12084.patch \
        file://CVE-2025-13836.patch \
        file://CVE-2025-13837.patch \
        file://0001-sysconfig.py-use-platlibdir-also-for-purelib.patch \
        file://0001-Lib-pty.py-handle-stdin-I-O-errors-same-way-as-maste.patch \
        file://deterministic_imports.patch \
        file://0001-Update-test_sysconfig-for-posix_user-purelib.patch \
        file://0001-skip-no_stdout_fileno-test-due-to-load-variability.patch \
        file://0001-test_storlines-skip-due-to-load-variability.patch \
        file://0001-Lib-sysconfig.py-use-prefix-value-from-build-configu.patch \
"

SRC_URI:prepend = " \
        file://00001-rpath.patch \
        file://00251-change-user-install-location.patch \
        file://backport-CVE-2024-0397-gh-114572-Fix-locking-in-cert_store_stats-and-g.patch \
        file://backport-CVE-2024-4032-gh-113171-gh-65056-Fix-private-non-global-IP-ad.patch \
        file://backport-fix_xml_tree_assert_error.patch \
        file://backport-CVE-2024-6923-gh-121650-Encode-newlines-in-headers-and-verify-head.patch \
        file://backport-CVE-2024-7592-gh-123067-Fix-quadratic-complexity-in-parsing-quoted.patch \
        file://backport-CVE-2024-8088-gh-123270-Replaced-SanitizedNames-with-a-more-surgic.patch \
        file://backport-CVE-2024-6232-gh-121285-Remove-backtracking-when-parsing-tarf.patch \
        file://backport-CVE-2024-3219-1-gh-122133-Authenticate-socket-connection-for-so.patch \
        file://backport-CVE-2024-3219-2-gh-122133-Rework-pure-Python-socketpair-tests-t.patch \
        file://backport-CVE-2023-6597-gh-91133-tempfile.TemporaryDirectory-fix-symlin.patch \
        file://backport-CVE-2024-0450-gh-109858-Protect-zipfile-from-quoted-overlap-z.patch \
        file://backport-CVE-2024-9287.patch \
        file://backport-Fix-parsing-errors-in-email-_parseaddr.py.patch \
        file://backport-Revert-fixes-for-CVE-2023-27043.patch \
        file://backport-CVE-2023-27043.patch \
        file://backport-CVE-2025-0938.patch \
        file://add-the-sm3-method-for-obtaining-the-salt-value.patch \
        file://0001-add-loongarch64-support-for-python.patch \
        file://0001-expected_algs-list-to-include-TLS_SM4.patch \
"

# add sysconfigdata patch with lib64 to path, else will put error that can not found _sysconfigdata module
# the result is libdir in openeuler is /usr/lib64, but in ros is /usr/lib, so if a python package in openeuler
# has a relation with a python package in ros, it can not find openeuler python package in /usr/lib path
# Note: There is no need to patch native python so that it looks in the target sysroot; the same can be
# achieved with just an environment variable. Reference: poky's commit af4284d39d8(python3targetconfig.bbclass:
# use PYTHONPATH to point to the target config)
setup_target_config:append:class-native () {
        export PYTHONPATH=${STAGING_LIBDIR}/../lib64/python-sysconfigdata:$PYTHONPATH
}

# meta-openeuler layer does not need to build python3-native dependency packages,
# but gets them directly from the nativesdk tool
# Find header from nativesdk
CPPFLAGS:append:class-native = " ${@oe.utils.vartrue('OPENEULER_PREBUILT_TOOLS_ENABLE', \
    '-I${OPENEULER_NATIVESDK_SYSROOT}/usr/include \
     -I${OPENEULER_NATIVESDK_SYSROOT}/usr/include/ncursesw \
     -I${OPENEULER_NATIVESDK_SYSROOT}/usr/include/uuid', \
    '', d)} \
"

# Find library from nativesdk
LDFLAGS:append:class-native = " ${@oe.utils.vartrue('OPENEULER_PREBUILT_TOOLS_ENABLE', \
    '-L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib', '', d)}"
