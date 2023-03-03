PV = "2.74.4"
OPENEULER_REPO_NAME = "glib2"

OPENEULER_BRANCH = "openEuler-23.03"

# use new relocate-modules.patch to fix build error of glib-2.0-native
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# no such file, add dependency on libpcre
LIC_FILES_CHKSUM_remove = " file://glib/pcre/pcre.h;beginline=8;endline=36;md5=3e2977dae4ad05217f58c446237298fc \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=41890f71f740302b785c27661123bff5"

DEPENDS += "libpcre2"

# source version differs greatly from poky, use SRC_URI of a later version 
# from http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-core/glib-2.0/glib-2.0_2.72.3.bb
# mingw32 patch: 0001-Set-host_machine-correctly-when-building-with-mingw3.patch
SRC_URI = "file://glib-${PV}.tar.xz \
           "
EXTRA_OEMESON_remove = "-Dfam=false"

SRC_URI[sha256sum] = "0e82da5ea129b4444227c7e4a9e598f7288d1994bf63f129c44b90cfd2432172"

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

# for ERROR: glib-2.0-1_2.74.4-r0 do_package: 
# QA Issue: glib-2.0: Files/directories were installed but not shipped in any package:
#  /usr/libexec
#  /usr/libexec/gio-launch-desktop
FILES_${PN} += " ${libexecdir}/*gio-launch-desktop \"

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
