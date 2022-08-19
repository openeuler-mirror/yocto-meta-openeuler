# source bb: meta/recipes-devtools/tcltk/tcl_8.6.11.bb

PV = "8.6.12"

# modify fix_non_native_build_issue.patch for version 8.6.12
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

BASE_SRC_URI_remove = "${SOURCEFORGE_MIRROR}/tcl/${BPN}${PV}-src.tar.gz \
"

# source code package name has been changed
BASE_SRC_URI =+ "file://${BPN}-core${PV}-src.tar.gz \
"
# don't patch the openeuler patch that is incompatible with the current bb,
# otherwise it may cause build problems

SRC_URI[sha256sum] = "186748f1131cef3d637421a18d70892f808e526a29c694bebfeb1c540f98727c"

# no such patch in later version
SRC_URI_remove = "file://no_packages.patch \
"