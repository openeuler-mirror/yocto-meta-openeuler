PV = "2.68.1"
OPENEULER_REPO_NAME = "glib2"

# use new relocate-modules.patch to fix build error of glib-2.0-native
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI[sha256sum] = "241654b96bd36b88aaa12814efc4843b578e55d47440103727959ac346944333"

SRC_URI = "${GNOME_MIRROR}/glib/${SHRT_VER}/glib-${PV}.tar.xz \
    file://glib-2-glibc-2.34-close_range.patch \
"
# apply patches from poky
SRC_URI += " \
           file://run-ptest \
           file://0001-Fix-DATADIRNAME-on-uclibc-Linux.patch \
           file://Enable-more-tests-while-cross-compiling.patch \
           file://0001-Remove-the-warning-about-deprecated-paths-in-schemas.patch \
           file://0001-Install-gio-querymodules-as-libexec_PROGRAM.patch \
           file://0001-Do-not-ignore-return-value-of-write.patch \
           file://0010-Do-not-hardcode-python-path-into-various-tools.patch \
           file://0001-Set-host_machine-correctly-when-building-with-mingw3.patch \
           file://0001-Do-not-write-bindir-into-pkg-config-files.patch \
           file://0001-meson-Run-atomics-test-on-clang-as-well.patch \
           file://0001-gio-tests-resources.c-comment-out-a-build-host-only-.patch \
           file://0001-gio-tests-codegen.py-bump-timeout-to-100-seconds.patch \
"

# delete depends to shared-mime-info
SHAREDMIMEDEP_remove += "shared-mime-info"

# glib2-codegn is a collection of python scripts.
# here, remove the runtime depends of python3, to simplify build
# when python3 support becomes mature, remove the following codes
RDEPENDS_${PN}-codegen = ""
# glib needs meson, meson needs python3-natve
# here use nativesdk's meson-native and python3-native
DEPENDS_remove += "python3-native"

#delete depends to util-linux-native
PACKAGECONFIG_remove_class-target += "libmount"

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
