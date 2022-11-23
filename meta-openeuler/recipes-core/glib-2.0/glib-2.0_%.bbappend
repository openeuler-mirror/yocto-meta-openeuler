PV = "2.72.2"
OPENEULER_REPO_NAME = "glib2"

# use new relocate-modules.patch to fix build error of glib-2.0-native
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# no such file, add dependency on libpcre
LIC_FILES_CHKSUM_remove = " file://glib/pcre/pcre.h;beginline=8;endline=36;md5=3e2977dae4ad05217f58c446237298fc \
"

DEPENDS += "libpcre2"

# source version differs greatly from poky, use SRC_URI of a later version
# from http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-core/glib-2.0/glib-2.0_2.72.3.bb
# mingw32 patch: 0001-Set-host_machine-correctly-when-building-with-mingw3.patch
SRC_URI = "${GNOME_MIRROR}/glib/${SHRT_VER}/glib-${PV}.tar.xz \
           file://run-ptest \
           file://0001-Fix-DATADIRNAME-on-uclibc-Linux.patch \
           file://Enable-more-tests-while-cross-compiling.patch \
           file://0001-Remove-the-warning-about-deprecated-paths-in-schemas.patch \
           file://0001-Install-gio-querymodules-as-libexec_PROGRAM.patch \
           file://0001-Do-not-ignore-return-value-of-write.patch \
           file://0010-Do-not-hardcode-python-path-into-various-tools.patch \
           file://0001-Do-not-write-bindir-into-pkg-config-files.patch \
           file://0001-meson-Run-atomics-test-on-clang-as-well.patch \
           file://0001-gio-tests-resources.c-comment-out-a-build-host-only-.patch \
           "

SRC_URI_prepend = "file://backport-add-version-macros-for-GLib-2.74.patch \
           file://backport-gtype-Add-G_TYPE_FLAG_NONE.patch \
           file://backport-gioenums-Add-G_TLS_CERTIFICATE_FLAGS_NONE.patch \
           file://backport-gtestutils-Add-G_TEST_SUBPROCESS_DEFAULT.patch \
           file://backport-gsignal-Add-G_CONNECT_DEFAULT.patch \
           file://backport-giomodule-test-Dont-pass-a-magic-number-to-g_test_trap_subprocess.patch \
           file://backport-giochannel-Add-G_IO_FLAG_NONE.patch \
           file://backport-gmarkup-Add-G_MARKUP_PARSE_FLAGS_NONE.patch \
           file://backport-gregex-Add-G_REGEX_DEFAULT-G_REGEX_MATCH_DEFAULT.patch \
           file://backport-replace-pcre1-with-pcre2.patch \
           file://backport-gregex-format-specifier-for-localized-error-message.patch \
           file://backport-gregex-ensure-we-translate-the-errcode.patch \
           file://backport-gregex-Free-match-info-if-offset-matching-recalc-failed.patch \
           file://backport-gregex-use-G_REGEX_OPTIMIZE-flag-to-enable-JIT-compilation.patch \
           file://backport-gregex-use-g_debug-instead-of-g_warning-in-case-JIT-is-not-available.patch \
           file://backport-gregex-do-not-set-match-and-recursion-limits-on-match-context.patch \
           file://backport-gregex-add-original-test-case.patch \
           file://backport-gregex-use-correct-size-for-pcre2_pattern_info.patch \
           file://backport-regex-Add-debug-strings-for-compile-and-match-option-flags.patch \
           file://backport-regex-Actually-check-for-match-options-changes.patch \
           file://backport-regex-Do-not-mix-PCRE2-Compile-Match-Newline-and-BSR-flags.patch \
           file://backport-regex-Add-test-for-gtksourceview-regression.patch \
           file://backport-gregex-Mark-g_match_info_get_regex-as-transfer-none.patch \
           file://backport-gregex-Do-not-try-access-the-undefined-match-offsets.patch \
           file://backport-gregex-Fix-a-potential-PCRE2-code-leak-on-reallocation-failures.patch \
           file://backport-regex-Use-size-types-more-in-line-with-PCRE2-returned-values.patch \
           file://backport-gregex-Handle-the-case-we-need-to-re-allocate-the-match-data.patch \
           file://backport-gregex-Avoid-re-allocating-if-we-have-no-size-change.patch \
           file://backport-regex-Compute-the-offsets-size-based-on-match-results.patch \
           file://backport-regex-Avoid-allocating-offsets-until-we-ve-a-match.patch \
           file://backport-regex-Handle-JIT-errors-more-explicitly.patch \
           file://backport-regex-Make-possible-to-test-replacements-with-options.patch \
           file://backport-regex-Do-not-use-JIT-when-using-unsupported-match-options.patch \
           file://backport-regex-Perform-more-tests-both-with-and-without-optimizations.patch \
           file://backport-gsocketclient-Fix-still-reachable-references-to-cancellables.patch \
           file://backport-Add-lock-in-_g_get_unix_mount_points-around-fsent-functions.patch \
           file://backport-g_get_unix_mount_points-reduce-syscalls-inside-loop.patch \
           file://backport-xdgmime-fix-double-free.patch \
           file://backport-Implement-GFileIface.set_display_name-for-resource-files.patch \
           file://backport-tests-dbus-appinfo-Add-test-case-for-flatpak-opening-an-invalid-file.patch \
           file://backport-documentportal-Fix-small-leak-in-add_documents-with-empty-URI-list.patch \
           file://backport-gio-tests-gdbus-proxy-threads-Unref-GVariant-s-that-we-own.patch \
           file://backport-gio-tests-gdbus-peer-Unref-cached-property-GVariant-value.patch \
           file://backport-gdesktopappinfo-Unref-the-GDBus-call-results.patch \
           file://backport-Handling-collision-between-standard-i-o-file-descriptors-and-newly-created-ones.patch \
           file://backport-glocalfileoutputstream-Do-not-double-close-an-fd-on-unlink-error.patch \
           "

SRC_URI[sha256sum] = "78d599a133dba7fe2036dfa8db8fb6131ab9642783fc9578b07a20995252d2de"

# delete depends to shared-mime-info
SHAREDMIMEDEP_remove += "shared-mime-info"

# glib2-codegn is a collection of python scripts.
# here, remove the runtime depends of python3, to simplify build
# when python3 support becomes mature, remove the following codes
RDEPENDS_${PN}-codegen = ""
# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS_remove += "python3-native"

# delete depends to util-linux-native
PACKAGECONFIG_remove_class-target += "libmount"
# no internal_pcre configuration option
PACKAGECONFIG[system-pcre] = ""

# glib-2.0 will inherit gio-module-cache.bbclass to update
# gio module after glib-2.0 is installed.
# to update the cache, gio-querymodules of glib-2.0 will be called.
# gio-querymodules is a target binary which can't be directly executed in host
# to do this, yocto use qemu user mode to simulate the execution of gio-querymodules.
# The call of qemu user mode will make things more complex, so better not to use
# A workaround is to delay the call of  gio-querymodules in target.
# Here, we set GIO_MODULLE_PACKAGES to empty to bypass the gio_module_cache_common in
# gio-module-cache.bbclass
# In future, if we figure out the related stuff of gio-querymodules, we can remove the
# following codes
GIO_MODULE_PACKAGES = ""

# rpath may generate by meson and may not auto delete rpath, it is no secure, so let we do it as a workaround
do_install_append () {
    if [ -f ${D}${libexecdir}/gio-querymodules${EXEEXT} ]; then
        chrpath --delete ${D}${libexecdir}/gio-querymodules${EXEEXT}
    fi
    if [ -f ${D}${libexecdir}/${MLPREFIX}gio-querymodules${EXEEXT} ]; then
        chrpath --delete ${D}${libexecdir}/${MLPREFIX}gio-querymodules${EXEEXT}
    fi
    chrpath --delete ${D}${libdir}/libgio-2.0.so
    chrpath --delete ${D}${libdir}/libgthread-2.0.so
    chrpath --delete ${D}${libdir}/libgobject-2.0.so
    chrpath --delete ${D}${libdir}/libgmodule-2.0.so
}

