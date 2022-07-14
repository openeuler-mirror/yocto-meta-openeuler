PV = "2.37.2"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove += " \
           file://avoid_parallel_tests.patch \
           file://Automake-use-EXTRA_LTLIBRARIES-instead-of-noinst_LTL.patch \
"

# files, patches that come from openeuler
SRC_URI += " \
           file://util-linux/2.36-login-lastlog-create.patch \
           file://util-linux/backport-CVE-2021-3995.patch \
           file://util-linux/backport-CVE-2021-3996.patch \
           file://util-linux/realloc-buffer-when-header-size-changed.patch \
           file://util-linux/fix-size-use-for-stdin.patch \
           file://util-linux/segmentation-fault-on-invalid-unicode-input-passed-to-s-option.patch \
           file://util-linux/backport-fix-by-ignoring-EINVAL-on-remount-of-proc.patch \
           file://util-linux/Add-check-to-resolve-uname26-version-test-failed.patch \
           file://util-linux/SKIPPED-no-root-permissions-test.patch \
"

SRC_URI[sha256sum] = "6a0764c1aae7fb607ef8a6dd2c0f6c47d5e5fd27aa08820abaad9ec14e28e9d9"
