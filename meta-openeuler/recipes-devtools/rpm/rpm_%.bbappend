PV = "4.17.0"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# delete useless patches form rpm_4.16.1.3.bb
SRC_URI:remove = " \
    git://github.com/rpm-software-management/rpm;branch=rpm-4.16.x;protocol=https \
            file://0001-Fix-build-with-musl-C-library.patch \
            file://0011-Do-not-require-that-ELF-binaries-are-executable-to-b.patch \
            file://0001-rpm-rpmio.c-restrict-virtual-memory-usage-if-limit-s.patch \
           file://0001-CVE-2021-3521.patch \
           file://0002-CVE-2021-3521.patch \
           file://0003-CVE-2021-3521.patch \
"

SRC_URI:append = " \
            file://0001-docs-do-not-build-manpages-requires-pandoc.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        http://ftp.rpm.org/releases/rpm-4.17.x/${BPN}-${PV}.tar.bz2 \
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
"

SRC_URI[sha256sum] = "2e0d220b24749b17810ed181ac1ed005a56bbb6bc8ac429c21f314068dc65e6a"

##openeuler rpm not support --without-lua
EXTRA_OECONF:remove = " --without-lua"
DEPENDS += "lua"
DEPENDS:remove = "db"

PACKAGECONFIG:append = "sqlite zstd ndb"
PACKAGECONFIG[sqlite] = "--enable-sqlite=yes,--enable-sqlite=no,sqlite3"
PACKAGECONFIG[ndb] = "--enable-ndb,--disable-ndb"
PACKAGECONFIG[bdb-ro] = "--enable-bdb-ro,--disable-bdb-ro"
PACKAGECONFIG[zstd] = "--enable-zstd=yes,--enable-zstd=no,zstd"

RRECOMMENDS:${PN}:remove = " rpm-build"
SSTATE_HASHEQUIV_FILEMAP = " \
    populate_sysroot:*/rpm/macros:${TMPDIR} \
    populate_sysroot:*/rpm/macros:${COREBASE} \
    "


# remove the following actios for pythondistdeps.py after upgrade to new poky
do_install:prepend() {
    # no file in new rpm version, touch one before use
    mkdir -p ${D}${libdir}/rpm/
    touch ${D}${libdir}/rpm/pythondistdeps.py
}
do_install:append() {
    rm -f ${D}${libdir}/rpm/pythondistdeps.py
}
