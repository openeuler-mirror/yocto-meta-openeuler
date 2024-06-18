PV = "4.17.0"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# delete useless patches form rpm_4.16.1.3.bb
SRC_URI_remove = " \
    git://github.com/rpm-software-management/rpm;branch=rpm-4.16.x;protocol=https \
    file://0001-Fix-build-with-musl-C-library.patch \
    file://0011-Do-not-require-that-ELF-binaries-are-executable-to-b.patch \
    file://0001-rpm-rpmio.c-restrict-virtual-memory-usage-if-limit-s.patch \
    file://0001-CVE-2021-3521.patch \
    file://0002-CVE-2021-3521.patch \
    file://0003-CVE-2021-3521.patch \
    file://0001-Add-a-color-setting-for-mips64_n32-binaries.patch \
"

SRC_URI_append = " \
            file://0001-docs-do-not-build-manpages-requires-pandoc.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://${BPN}-${PV}.tar.bz2 \
        file://Unbundle-config-site-and-add-RPM-LD-FLAGS-macro.patch \
        file://rpm-4.12.0-rpm2cpio-hack.patch \
        file://add-dist-to-release-by-default.patch \
        file://revert-always-execute-file-trigger-scriptlet-callbac.patch \
        file://bugfix-rpm-4.11.3-add-aarch64_ilp32-arch.patch \
        file://bugfix-rpm-4.14.2-wait-once-get-rpmlock-fail.patch \
        file://Generate-digest-lists.patch \
        file://Add-digest-list-plugin.patch \
        file://Don-t-add-dist-to-release-if-it-is-already-there.patch \
        file://Generate-digest-lists-before-calling-genCpioListAndH.patch \
        file://call-process_digest_list-after-files-are-added.patch \
        file://fix-lsetxattr-error-in-container.patch \
        file://rpm-selinux-plugin-check-context-file-exist.patch \
        file://get-in-use-of-ndb.patch \
        file://still-in-use-of-python-scripts-from-old-version.patch \
        file://Add-loongarch-architecture-support.patch \
        file://Fix-digest_list_counter.patch \
        file://Check-rpm-parser.patch \
        file://Remove-digest-list-from-the-kernel-during-package-re.patch \
        file://Add-license-to-digest_list.c.patch \
        file://Avoid-generating-digest-lists-if-they-are-already-pa.patch \
        file://dont-remove-ima-xattr-of-parser-when-upgrading.patch \
        file://backport-Use-root-as-default-UID_0_USER-and-UID_0_GROUP.patch \
        file://backport-Check-file-iterator-for-being-NULL-consistently.patch \
        file://backport-Process-MPI-s-from-all-kinds-of-signatures.patch \
        file://backport-Refactor-pgpDigParams-construction-to-helper-functio.patch \
        file://backport-Validate-and-require-subkey-binding-signatures-on-PG.patch \
        file://backport-Revert-Explictly-skip-non-installed-files-on-erasur.patch \
        file://backport-Fix-hash-context-leak.patch \
        file://backport-Fix-hashlen-overflow.patch \
        file://backport-Fix-some-Lua-stack-leaks-in-our-initialization-code.patch \
        file://backport-Simplify-rpm_print-fixing-a-Lua-stack-leak-as-a-bonu.patch \
        file://backport-Switch-the-floating-point-type-in-rpmhook-from-float.patch \
        file://backport-Fix-a-memleak-in-ndb-from-opened-but-not-closed-dbis.patch \
        file://backport-Fix-possible-NULL-pointer-dereference-in-rpmfcClassi.patch \
        file://backport-Fix-old-Python-ts.check-argument-order-regression.patch \
        file://backport-Fix-memory-leak-in-pgpPrtParams.patch \
        file://backport-Fix-use-after-free-in-haveSignature.patch \
        file://backport-Close-file-before-replacing-signed.patch \
        file://backport-Fix-__cplusplus-misspelled-as-_cplusplus.patch \
        file://backport-treat-0-as-valid-file-descriptor.patch \
        file://backport-Skip-recorded-symlinks-in-setperms-RhBug-1900662.patch \
        file://backport-Check-that-the-CRC-length-is-correct.patch \
        file://backport-Make-rpmfiSetFX-return-code-meaningful.patch \
        file://backport-Avoid-reading-out-of-bounds-of-the-i18ntable.patch \
        file://backport-rpmkeys-exit-non-zero-on-I-O-errors.patch \
        file://backport-Prevent-NULL-deref-in-rpmfsGetStates.patch \
        file://backport-Fix-memory-leak-in-pgpPrtParams-1.patch \
        file://backport-Fix-return-value-checks-in-OpenSSL-code.patch \
        file://backport-Avoid-double-frees-if-EVP_PKEY_assign_RSA-fails.patch \
        file://backport-Require-creation-time-to-be-unique-and-hashed.patch \
        file://backport-Add-a-hashed-flag-to-pgpPrtSubtype.patch \
        file://backport-Parse-key-usage-flags.patch \
        file://backport-Ignore-subkeys-that-cannot-be-used-for-signing.patch \
        file://backport-Avoid-unneded-MPI-reparsing.patch \
        file://backport-Fix-OpenPGP-key-ID-parsing-regression.patch \
        file://backport-Fix-changelog-parsing-affecting-caller-timezone-stat.patch \
        file://backport-rpm2cpio.sh-Don-t-drop-newlines-from-header-sizes.patch \
        file://backport-Prevent-readelf-internet-access-during-rpaths-checki.patch \
        file://backport-Fix-short-circuiting-of-version-strings-in-expressio.patch \
        file://backport-Add-optional-callback-on-directory-changes-during-rp.patch \
        file://backport-CVE-2021-35937-CVE-2021-35939.patch \
        file://backport-Consolidate-skipped-hardlink-with-content-case-with-.patch \
        file://backport-Fix-sanitize-the-hardlink-metadata-setting-logic.patch \
        file://backport-Convert-the-file-creation-steps-the-at-family-of-cal.patch \
        file://backport-Bury-rpmio-FD-use-to-fsmUnpack.patch \
        file://backport-Return-descriptor-of-created-file-from-fsmMkfile.patch \
        file://backport-CVE-2021-35938.patch \
        file://backport-rpm2cpio.sh-strip-null-bytes-with-tr.patch \
        file://backport-rpm2cpio.sh-only-read-needed-bytes-of-file-magic.patch \
        file://backport-Fix-rpm-lua-rpm_vercmp-error-message-if-second-argum.patch \
        file://backport-Make-pgpPubkeyFingerprint-do-something-meaningful-ag.patch \
        file://backport-Fix-possible-descriptor-leak-in-fsmOpenat.patch \
        file://backport-Move-file-metadata-setting-back-to-unpack-stage.patch \
        file://backport-Fix-header-leak-in-rpmInstall.patch \
        file://backport-Fix-eiu-sourceURL-info-leak-in-rpmInstall.patch \
        file://backport-Fix-h-blob-leak-when-installing-source-rpms.patch \
        file://backport-Fix-Header-leak-when-running-rpm2cpio.patch \
        file://backport-Use-unsigned-integers-more-consistently-in-the-handl.patch \
        file://backport-Fix-file-leak-when-src-rpm-in-URL-format-is-used-for.patch \
        file://backport-Fix-BANames-leak-in-handlePreambleTag.patch \
        file://backport-Fix-prog-leak-in-parseScript.patch \
        file://backport-Fix-elf-leak-in-getElfColor.patch \
        file://backport-Fix-sbp-leak-when-running-rpmbuild-with-quiet.patch \
        file://backport-Fix-memleak-when-running-generate_buildrequires.patch \
        file://backport-Fix-memleak-when-fsmRename-failed-in-fsmCommit.patch \
        file://backport-Fix-fileleak-and-memleak-in-rpmInstall.patch \
        file://backport-Fix-fileleak-when-urlGetFile-fails-in-rpmInstall.patch \
        file://backport-Fix-install-of-block-and-character-special-files-219.patch \
        file://backport-Use-fd-based-ops-for-metadata-in-FA_TOUCH-mode-too-w.patch \
        file://backport-Add-a-test-for-special-device-node-installation.patch \
        file://backport-support-for-POSIX-getopt-behaviour.patch \
        file://backport-Use-proper-type-for-copyTagsFromMainDebug.patch \
        file://backport-Fix-a-copy-paste-help-description-of-whatconflicts-R.patch \
        file://backport-Fix-a-segfault-on-a-non-stringable-argument-to-macro.patch \
        file://backport-Remove-obscure-check-for-package-build-time-from-reb.patch \
        file://backport-Fix-possible-null-pointer-reference-in-ndb.patch \
        file://backport-Fix-rpmDigestBundleFinal-and-Update-return-code-on-i.patch \
        file://backport-Actually-return-an-error-in-parseScript-if-parsing-f.patch \
        file://backport-Check-inside-root-when-querying-for-files.patch \
        file://backport-Fix-regression-on-ctrl-c-during-transaction-killing-.patch \
        file://backport-Use-unsigned-integers-for-buildtime-too-for-Y2K38-sa.patch \
        file://backport-Fix-a-theoretical-use-of-uninitialized-struct-member.patch \
        file://backport-Fix-spec-parser-leaks-from-trans-f-file.patch \
        file://backport-Tip-toe-around-rpmfiFN-thin-ice-in-fsm.patch \
        file://backport-Fix-a-memleak-on-invalid-command-line-options.patch \
        file://backport-Let-eBPF-ELF-files-be-packaged-in-noarch-packages.patch \
        file://fix-macros-autopath-num-error.patch \
        file://backport-Fix-some-int-enum-confusion-in-the-build-code.patch \
        file://backport-Use-the-internal-DB_CTRL-enum-for-intenal-uses-consi.patch \
        file://backport-An-enumeration-is-not-a-bitfield-use-an-integer-inst.patch \
        file://backport-Fix-an-enum-int-type-mismatch-in-rpmfiArchiveReadToF.patch \
        file://backport-Fix-an-enum-int-type-mismatch-in-transaction-verify-.patch \
        file://backport-Fix-enum-type-mismatch-in-rpmTagGetValue.patch \
        file://backport-Don-t-segfault-on-missing-priority-tag.patch \
"

SRC_URI[sha256sum] = "2e0d220b24749b17810ed181ac1ed005a56bbb6bc8ac429c21f314068dc65e6a"

##openeuler rpm not support --without-lua
EXTRA_OECONF_remove = " --without-lua"
DEPENDS += "lua"
DEPENDS_remove = "db"

PACKAGECONFIG_append = " sqlite zstd ndb "
PACKAGECONFIG[sqlite] = "--enable-sqlite=yes,--enable-sqlite=no,sqlite3"
PACKAGECONFIG[ndb] = "--enable-ndb,--disable-ndb"
PACKAGECONFIG[bdb-ro] = "--enable-bdb-ro,--disable-bdb-ro"
PACKAGECONFIG[zstd] = "--enable-zstd=yes,--enable-zstd=no,zstd"

RRECOMMENDS_${PN}_remove = " rpm-build"
SSTATE_HASHEQUIV_FILEMAP = " \
    populate_sysroot:*/rpm/macros:${TMPDIR} \
    populate_sysroot:*/rpm/macros:${COREBASE} \
    "


# remove the following actios for pythondistdeps.py after upgrade to new poky
do_install_prepend() {
    # no file in new rpm version, touch one before use
    mkdir -p ${D}${libdir}/rpm/
    touch ${D}${libdir}/rpm/pythondistdeps.py
}
do_install_append() {
    rm -f ${D}${libdir}/rpm/pythondistdeps.py
}
