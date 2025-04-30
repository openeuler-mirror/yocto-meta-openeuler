PV = "3.11.6"

SRC_URI:prepend = "file://Python-${PV}.tar.xz \
"

# remove conflicting patch
SRC_URI:remove = "file://0001-Skip-failing-tests-due-to-load-variability-on-YP-AB.patch"

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
