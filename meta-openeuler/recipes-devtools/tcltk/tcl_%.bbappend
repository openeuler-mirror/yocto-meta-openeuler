# source bb: meta/recipes-devtools/tcltk/tcl_8.6.11.bb

PV = "8.6.12"

# modify fix_non_native_build_issue.patch for version 8.6.12
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

BASE_SRC_URI_remove = "${SOURCEFORGE_MIRROR}/tcl/${BPN}${PV}-src.tar.gz \
"

# source code package name has been changed
BASE_SRC_URI =+ "file://${BPN}-core${PV}-src.tar.gz \
"
# the list patchs that src-openeuler offerd can not patch successful, the first patch is faild
# SRC_URI += "file://tcl-8.6.12-autopath.patch
#             file://tcl-8.6.12-conf.patch
#             file://tcl-8.6.10-hidden.patch
#             file://tcl-8.6.10-tcltests-path-fix.patch
#             file://stay-out-of-internals-when-nice-interfaces-are-avail.patch
#             file://oops.patch
#             file://File-not-found-should-be-ignored-silently.patch
# "

# don't patch the openeuler patch that is incompatible with the current bb,
# otherwise it may cause build problems

SRC_URI[sha256sum] = "186748f1131cef3d637421a18d70892f808e526a29c694bebfeb1c540f98727c"

# no such patch in later version
SRC_URI_remove = " \
           file://fix_issue_with_old_distro_glibc.patch \
"

# we don't need .c file pack in rootfs
FILES_${PN}-dev_append += "${libdir}/tcl8.6/*.c"
