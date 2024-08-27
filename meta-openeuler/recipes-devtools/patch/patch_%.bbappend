
PV = "2.7.6"

# apply openeuler source package and patches
SRC_URI = "file://${BP}.tar.xz \
        file://patch-CVE-2018-1000156.patch \
        file://CVE-2018-6951.patch \
        file://Fix-check-of-return-value-of-fwrite.patch \
        file://Don-t-leak-temporary-file-on-failed-ed-style-patch.patch \
        file://Don-t-leak-temporary-file-on-failed-multi-file-ed-st.patch \
        file://Fix-swapping-fake-lines-in-pch_swap.patch \
        file://CVE-2018-20969-and-CVE-2019-13638.patch \
        file://CVE-2019-13636.patch \
        file://Avoid-set_file_attributes-sign-conversion-warnings.patch \
        file://Test-suite-compatibility-fixes.patch \
        file://Test-suite-fix-Korn-shell-incompatibility.patch \
        file://backport-maint-avoid-warnings-from-GCC8.patch \
        file://backport-Make-the-debug-2-output-more-useful.patch \
        file://backport--Improve-support-for-memory-leak-detection.patch \
        file://backport-Skip-ed-test-when-the-ed-utility-is-not-installed.patch \
        file://backport-Abort-when-cleaning-up-fails.patch \
        file://backport-Don-t-crash-when-RLIMIT_NOFILE-is-set-to-RLIM_INFINI.patch \
        file://backport-Avoid-invalid-memory-access-in-context-format-diffs.patch \
        file://backport-Fix-failed-assertion-outstate-after_newline.patch \
        file://backport-Add-missing-section-tests-to-context-format-test-cas.patch \
        file://backport-Fix-test-for-presence-of-BASH_LINENO-0.patch \
"

# the following openEuler patch will cause compilation to fail 
# file://patch-selinux.patch
# file://backport-Pass-the-correct-stat-to-backup-files.patch
