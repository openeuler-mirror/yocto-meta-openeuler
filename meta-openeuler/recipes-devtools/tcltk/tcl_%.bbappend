# source bb: meta/recipes-devtools/tcltk/tcl_8.6.11.bb

PV = "8.6.10"

# modify fix_non_native_build_issue.patch for version 8.6.12
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

BASE_SRC_URI_remove = "${SOURCEFORGE_MIRROR}/tcl/${BPN}${PV}-src.tar.gz \
"

# source code package name has been changed
BASE_SRC_URI =+ "file://${BPN}-core${PV}-src.tar.gz \
"
# don't patch the openeuler patch that is incompatible with the current bb,
# otherwise it may cause build problems

SRC_URI[sha256sum] = "77c274fa3b38e8e9f85ff9e41ad754ea48b3baa35d65a43f7b6ee1453d4b43f5"

# we don't need .c file pack in rootfs
FILES_${PN}-dev_append += "${libdir}/tcl8.6/*.c"
