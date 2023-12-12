
OPENEULER_SRC_URI_REMOVE = "https http"

OPENEULER_REPO_NAME = "glib2"

PV = "2.74.4"

# license update
LIC_FILES_CHKSUM = "file://COPYING;md5=41890f71f740302b785c27661123bff5 \
                    file://glib/glib.h;beginline=4;endline=17;md5=72f7cc2847407f65d8981ef112e4e630 \
                    file://LICENSES/LGPL-2.1-or-later.txt;md5=41890f71f740302b785c27661123bff5 \
                    file://gmodule/gmodule.h;beginline=4;endline=17;md5=72f7cc2847407f65d8981ef112e4e630 \
                    file://docs/reference/COPYING;md5=f51a5100c17af6bae00735cd791e1fcc"

# use new relocate-modules.patch to fix build error of glib-2.0-native
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# remove conflicting patches
SRC_URI:remove = "file://Enable-more-tests-while-cross-compiling.patch \
           file://0001-Do-not-ignore-return-value-of-write.patch \
           "

# openeuler patch
SRC_URI:prepend = " \
        file://glib-${PV}.tar.xz \
        file://backport-gdbusinterfaceskeleton-Fix-a-use-after-free-of-a-GDBusMethodInvocation.patch \
"

# fix arm build error: 'errno' undeclared (first use in this function)
SRC_URI:append = " file://0001-fix-compile-error-for-arm32.patch"

SRC_URI[sha256sum] = "0e82da5ea129b4444227c7e4a9e598f7288d1994bf63f129c44b90cfd2432172"

# delete depends to shared-mime-info
SHAREDMIMEDEP:remove = "shared-mime-info"

# glib2-codegn is a collection of python scripts.
# here, remove the runtime depends of python3, to simplify build
# when python3 support becomes mature, remove the following codes
RDEPENDS:${PN}-codegen = ""

# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS:remove = "python3-native"

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
do_install:append () {
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


# keep same as later version bb below
do_install:append:class-target () {
        # https://gitlab.gnome.org/GNOME/glib/-/issues/2810
        rm -f ${D}${datadir}/installed-tests/glib/thread-pool-slow.test
}

DEPENDS:remove = "libpcre"
DEPENDS:append = " libpcre2"

EXTRA_OEMESON:remove = "-Dfam=false"

RDEPENDS:${PN}-ptest += "desktop-file-utils"

# for ERROR: glib-2.0-1_2.74.4-r0 do_package: 
# QA Issue: glib-2.0: Files/directories were installed but not shipped in any package:
#  /usr/libexec
#  /usr/libexec/gio-launch-desktop
FILES:${PN} += "${libexecdir}/*gio-launch-desktop"

# this is a workaround: the use of qemu is immature now
# when using qemu-usermode in MACHINE_FEATURES, there will be a error:
# xxx-objcopy: Unable to recognise the format of the input file `gio/tests/test_resources.o'
MACHINE_FEATURES:remove = "qemu-usermode"
