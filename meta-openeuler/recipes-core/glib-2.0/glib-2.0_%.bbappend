
OPENEULER_REPO_NAME = "glib2"

# openeuler patch
SRC_URI:prepend = " \
        file://glib-${PV}.tar.xz \
"

SRC_URI:remove = " \
    file://0001-Do-not-write-bindir-into-pkg-config-files.patch \
    file://0001-gio-tests-portal-support-Fix-snap-test-ordering-race.patch \
    file://0001-glocalfile-Sum-apparent-size-only-for-files-and-syml.patch \
"

SRC_URI:append = " \
    file://gspawn-eperm.patch \
    file://backport-gmessages-fix-dropping-irrelevant-log-domains.patch \
    file://backport-gutils-Fix-an-unlikely-minor-leak-in-g_build_user_data_dir.patch \
"

FILES:${PN}:append = " \
    ${datadir}/glib-2.0/dtds \
"

# fix arm build error: 'errno' undeclared (first use in this function)
SRC_URI:append:arm = " file://0001-fix-compile-error-for-arm32.patch"

PV = "2.78.3"

# delete depends to shared-mime-info
SHAREDMIMEDEP:remove = "${@['', 'shared-mime-info']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

# glib2-codegn is a collection of python scripts.
# here, remove the runtime depends of python3, to simplify build
# when python3 support becomes mature, remove the following codes
RDEPENDS:${PN}-codegen:openeuler-prebuilt = ""

# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS:remove = "${@['', 'python3-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

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
GIO_MODULE_PACKAGES:openeuler-prebuilt = ""

# rpath may generate by meson and may not auto delete rpath, it is no secure, so let we do it as a workaround
do_install:append () {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ];then
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
    fi
}
