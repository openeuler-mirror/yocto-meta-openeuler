PV = "4.18.2"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# fix-declaration.patch same as backport-Fix-compiler-error-on-clang.patch in openeuler
# ea3187cfcf9cac87e5bc5e7db79b0338da9e355e has merged in new version
SRC_URI:remove = " \
        file://fix-declaration.patch \
        file://ea3187cfcf9cac87e5bc5e7db79b0338da9e355e.patch \
"

# files, patches that come from openeuler
# these patches not apply for unsupport arch:
#  rpm-Add-sw64-architecture.patch
#  Add-loongarch-architecture-support.patch 
#  add-default-machine-name-to-support-loongarch.patch 
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://Unbundle-config-site-and-add-RPM-LD-FLAGS-macro.patch \
        file://rpm-4.12.0-rpm2cpio-hack.patch \
        file://add-dist-to-release-by-default.patch \
        file://revert-always-execute-file-trigger-scriptlet-callbac.patch \
        file://bugfix-rpm-4.11.3-add-aarch64_ilp32-arch.patch \
        file://bugfix-rpm-4.14.2-wait-once-get-rpmlock-fail.patch \
        file://get-in-use-of-ndb.patch \
        file://still-in-use-of-python-scripts-from-old-version.patch \
        file://backport-revert-Permit-building-rpm-from-git-without-pandoc.patch \
        file://backport-Check-inside-root-when-querying-for-files.patch \
        file://backport-Use-unsigned-integers-for-buildtime-too-for-Y2K38-sa.patch \
        file://backport-Fix-a-theoretical-use-of-uninitialized-struct-member.patch \
        file://backport-Fix-spec-parser-leaks-from-trans-f-file.patch \
        file://backport-Tip-toe-around-rpmfiFN-thin-ice-in-fsm.patch \
        file://backport-Fix-a-memleak-on-invalid-command-line-options.patch \
        file://backport-Let-eBPF-ELF-files-be-packaged-in-noarch-packages.patch \
        file://backport-Fix-some-int-enum-confusion-in-the-build-code.patch \
        file://backport-Use-the-internal-DB_CTRL-enum-for-intenal-uses-consi.patch \
        file://backport-An-enumeration-is-not-a-bitfield-use-an-integer-inst.patch \
        file://backport-Fix-an-enum-int-type-mismatch-in-rpmfiArchiveReadToF.patch \
        file://backport-Fix-an-enum-int-type-mismatch-in-transaction-verify-.patch \
        file://backport-Fix-enum-type-mismatch-in-rpmTagGetValue.patch \
        file://backport-Free-old-cookie-value-to-prevent-a-memory-leak.patch \
        file://backport-Fix-pointer-bogosity-in-rpmlog-callback.patch \
        file://backport-Fix-an-ancient-memleak-on-caps-parsing-add-tests.patch \
        file://backport-Fix-potential-use-of-uninitialized-pipe-array.patch \
        file://backport-Fix-potential-use-of-uninitialized-pgp-struct.patch \
        file://backport-Use-unsigned-integers-more-consistently-in-the-handl.patch \
        file://backport-Use-proper-type-for-copyTagsFromMainDebug.patch \
        file://Add-digest-list-plugin.patch \
        file://Add-IMA-digest-list-support.patch \
        file://rpm-selinux-plugin-check-context-file-exist.patch \
        file://disable-automatic-maintenance-also.patch \
        file://backport-Reset-recursion-depth-for-error-message.patch \
        file://backport-Fix-division-by-zero-in-elfdeps-RhBug-2299414.patch \
        file://backport-Make-sure-dirs-are-not-relocated-twice.patch \
        file://backport-Fix-root-relocation-regression.patch \
        file://backport-Fix-crash-on-Lua-file-trigger-exiting-with-return-ed.patch \
        file://backport-Fix-V-option-usage-in-our-tests.patch \
        file://backport-Remove-libtool-la-symlinks.patch \
        file://backport-Specify-the-private-key-in-rpm-addsign.patch \
        file://backport-Use-EVP_PKEY_verify-to-verify-DSA-signatures.patch \
        file://backport-No-longer-use-the-low-level-API-in-openssl-3.patch \
        file://backport-Add-ECDSA-support-to-digest_openssl.patch \
        file://backport-Support-NIST-P-521.patch \
        file://backport-Allow-signing-with-ECDSA-keys.patch \
        file://backport-Support-ECDSA-in-key-parsing.patch \
        file://backport-Fix-memleak-when-process-policies.patch \
        file://backport-Enforce-the-same-sanity-checks-on-db-add-and-rebuild.patch \
        file://backport-Fix-a-memory-leak-on-rpmdb-importdb.patch \
        file://backport-Require-macro-filenames-to-end-in-alphanum-char.patch \
        file://backport-Allow-version-to-be-omitted-in-the-replace-test-spec.patch \
        file://backport-Fix-wrong-return-code-on-O_DIRECTORY-open-of-invalid.patch \
        file://backport-Refactor-fsmOpenat-return-style-for-consistency-with.patch \
        file://backport-Report-unsafe-symlinks-during-installation-as-a-spec.patch \
        file://backport-Fix-FA_TOUCH-ed-files-getting-removed-on-failed-upda.patch \
        file://backport-Fix-race-condition-in-rpmioMkpath.patch \
        file://backport-Ignore-EPERM-for-root-when-setting-IMA-signature-xat.patch \
        file://backport-Fix-a-copy-paste-help-description-of-rpmbuild-rf-and.patch \
        file://backport-Return-1-from-fdSize-for-non-regular-files.patch \
        file://backport-Check-RPATH-and-RUNPATH-separately-in-check-rpaths.patch \
        file://backport-Avoid-Python-reference-leaks.patch \
        file://backport-Ensure-header-object-is-cleaned-even-in-case-of-an-e.patch \
        file://backport-revert-Make-brp-strip-comment-note-multi-process.patch \
        file://backport-rpmrc-Drop-left-over-free.patch \
        file://backport-Fix-segfault-in-rpmgraph.patch \
        file://backport-rpmgraph-Prevent-memory-leaks-in-error-handling.patch \
        file://backport-Fix-rpmds-trigger-index-to-be-optional-as-originally.patch \
        file://backport-Fix-rpmds-segfault-s-memleaks-on-incomplete-header-d.patch \
        file://backport-Split-testsuite-rpmdb-reset-to-a-macro-of-its-own.patch \
        file://backport-Add-a-test-for-CVE-2026-44605.patch \
        file://backport-CVE-2026-44605-Harden-the-ndb-implementation-against-integer-overfl.patch \
        file://backport-CVE-2026-78367.patch \
        file://backport-CVE-2026-84837-CVE-2026-84838-1.patch \
        file://backport-CVE-2026-84837-CVE-2026-84838-2.patch \
        file://backport-CVE-2026-84837-CVE-2026-84838-3.patch \
        file://backport-CVE-2026-84837-CVE-2026-84838-4.patch \
        file://backport-CVE-2026-84837-CVE-2026-84838-5.patch \
        file://backport-Make-the-hex-validator-helper-function-internally-available.patch \
        file://backport-CVE-2026-103242-1.patch \
        file://backport-CVE-2026-103242-2.patch \
        file://backport-CVE-2026-103242-3.patch \
        file://backport-CVE-2026-103242-4.patch \
        file://Support-sm2p256v1-of-ECDSA-and-sm3-of-hash.patch \
        file://support-config-enable-default-subr-macro.patch \
        file://huawei-fix-test-failed-basic-file-tigger-scripts.patch \
        file://fix-rpm-install-coredump-when-sigp-data-is-null.patch \
"

SRC_URI[sha256sum] = "2e0d220b24749b17810ed181ac1ed005a56bbb6bc8ac429c21f314068dc65e6a"


# openeuler configuration
PACKAGECONFIG:append = " ndb"
