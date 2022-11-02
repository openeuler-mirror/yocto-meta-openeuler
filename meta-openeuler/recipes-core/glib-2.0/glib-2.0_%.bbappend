PV = "2.68.1"
OPENEULER_REPO_NAME = "glib2"

# use new relocate-modules.patch to fix build error of glib-2.0-native
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# no such file, add dependency on libpcre
LIC_FILES_CHKSUM_remove = " file://glib/pcre/pcre.h;beginline=8;endline=36;md5=3e2977dae4ad05217f58c446237298fc \
"
DEPENDS += "libpcre"

# source version differs greatly from poky, use SRC_URI of a later version 
# from http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-core/glib-2.0/glib-2.0_2.72.3.bb
# mingw32 patch: 0001-Set-host_machine-correctly-when-building-with-mingw3.patch
SRC_URI_remove = "${GNOME_MIRROR}/glib/${SHRT_VER}/glib-${PV}.tar.xz \
"

SRC_URI = "file://glib-${PV}.tar.xz \
           file://run-ptest \
           file://0001-Fix-DATADIRNAME-on-uclibc-Linux.patch \
           file://0001-Remove-the-warning-about-deprecated-paths-in-schemas.patch \
           file://0001-Install-gio-querymodules-as-libexec_PROGRAM.patch \
           file://0001-Do-not-ignore-return-value-of-write.patch \
           file://0010-Do-not-hardcode-python-path-into-various-tools.patch \
           file://0001-Do-not-write-bindir-into-pkg-config-files.patch \
           file://0001-meson-Run-atomics-test-on-clang-as-well.patch \
           file://0001-gio-tests-resources.c-comment-out-a-build-host-only-.patch \
           "

SRC_URI += " \
	file://backport-Add-D-Bus-object-subtree-unregistration-tests.patch \
	file://backport-Add-lock-in-_g_get_unix_mount_points-around-fsent-functions.patch \
	file://backport-add-OOM-handling-in-mimemagic.patch \
	file://backport-application-Unset-the-registered-state-after-shutting-down.patch \
	file://backport-correctly-use-3-parameters-for-clise-range.patch \
	file://backport-documentportal-Fix-small-leak-in-add_documents-with-empty-URI-list.patch \
	file://backport-fix-a-memory-leak.patch \
	file://backport-Fix-memory-leak-in-gdbusauthmechanismsha1.patch \
	file://backport-gapplication-fix-arguments-leak-in-error-path.patch \
	file://backport-garray-buffer-overflow-fix.patch \
	file://backport-garray-Fix-integer-overflows-in-element-capacity-calculations.patch \
	file://backport-gdbusauth-fix-error-leak.patch \
	file://backport-gdbusmessage-Disallow-zero-length-elements-in-arrays.patch \
	file://backport-gdbusmethodinvocation-Drop-redundant-quote-from-warning.patch \
	file://backport-gdbusmethodinvocation-Fix-a-leak-on-an-early-return-path.patch \
	file://backport-gdbusmethodinvocation-Fix-dead-code-for-type-checking-GetAll.patch \
	file://backport-gdbusobjectmanagerservice-fix-leak-in-error-path.patch \
	file://backport-gdesktopappinfo-Unref-the-GDBus-call-results.patch \
	file://backport-gdtlsconnection-Fix-a-check-for-a-vfunc-being-implemented.patch \
	file://backport-gfileenumerator-fix-leak-in-error-path.patch \
	file://backport-g_get_unix_mount_points-reduce-syscalls-inside-loop.patch \
	file://backport-gio-tests-gdbus-peer-Unref-cached-property-GVariant-value.patch \
	file://backport-gio-tests-gdbus-proxy-threads-Unref-GVariant-s-that-we-own.patch \
	file://backport-gio-tool-Fix-a-minor-memory-leak.patch \
	file://backport-glocalfileinfo-Fix-atime-mtime-mix.patch \
	file://backport-glocalfileoutputstream-Do-not-double-close-an-fd-on-unlink-error.patch \
	file://backport-gopenuriportal-Fix-GVariantBuilder-and-string-leakage.patch \
	file://backport-gprintf-Fix-a-memory-leak-with-an-invalid-format.patch \
	file://backport-gproxyaddressenumerator-Fix-string-leakage-on-an-invalid-input.patch \
	file://backport-gsocketclient-Fix-still-reachable-references-to-cancellables.patch \
	file://backport-gsocks5proxy-Fix-buffer-overflow-on-a-really-long-domain-name.patch \
	file://backport-gsocks5proxy-Handle-EOF-when-reading-from-a-stream.patch \
	file://backport-gtestdbus-Print-the-dbus-address-on-a-specific-FD-intead-of-stdout.patch \
	file://backport-gthread-posix-Free-a-memory-leak-on-error-path.patch \
	file://backport-gtype-Fix-pointer-being-dereferenced-despite-NULL-check.patch \
	file://backport-gunixmounts-Add-cache-to-g_unix_mount_points_get.patch \
	file://backport-gutf8-add-string-length-check.patch \
	file://backport-gutils-Avoid-segfault-in-g_get_user_database_entry.patch \
	file://backport-gutils-Fix-g_find_program_in_path-to-return-an-absolute-path.patch \
	file://backport-gvariant-Fix-memory-leak-on-a-TYPE-CHECK-failure.patch \
	file://backport-gvariant-Fix-pointers-being-dereferenced-despite-NULL-checks.patch \
	file://backport-gvariant-serialiser-Prevent-unbounded-recursion.patch \
	file://backport-Handling-collision-between-standard-i-o-file-descriptors-and-newly-created-ones.patch \
	file://backport-Implement-GFileIface.set_display_name-for-resource-files.patch \
	file://backport-tests-Add-some-tests-for-g_string_append_vprintf.patch \
	file://backport-tests-Add-some-tests-for-g_vasprintf-invalid-format-strings.patch \
	file://backport-tests-Add-unit-tests-for-GDBusMethodInvocation.patch \
	file://backport-tests-dbus-appinfo-Add-test-case-for-flatpak-opening-an-invalid-file.patch \
	file://backport-xdgmime-fix-double-free.patch \
"

# These patches can't apply from openEuler:
# backport-gdbusconnection-Add-some-ownership-annotations.patch
# backport-gdbusconnection-Fix-race-between-method-calls-and-object-unregistration.patch
# backport-gdbusconnection-Make-ExportedInterface-ExportedSubtree-refcounted.patch
# backport-gdbusconnection-Move-ExportedSubtree-definition.patch
# backport-gopenuriportal-Fix-a-use-after-free-on-an-error-path.patch
# backport-gdbusconnection-Fix-race-between-subtree-method-call-and-unregistration.patch

SRC_URI[sha256sum] = "241654b96bd36b88aaa12814efc4843b578e55d47440103727959ac346944333"

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

