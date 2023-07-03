# source bb: meta/recipes-devtools/tcltk/tcl_8.6.11.bb
OPENEULER_SRC_URI:remove = "http https git"

PV = "8.6.13"

# remove upstream software
BASE_SRC_URI:remove = "${SOURCEFORGE_MIRROR}/tcl/tcl-core${PV}-src.tar.gz \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/tcl/:"

# fix_issue_with_old_distro_glibc.patch only needs to be used when built on glibc older than 2.14
# fix_non_native_build_issue.patch cannot be applied
SRC_URI:remove = "file://fix_issue_with_old_distro_glibc.patch \"

# source code package name has been changed
# openEuler patches will not cause problem, they can be successfully patched
BASE_SRC_URI += "file://${BPN}-core${PV}-src.tar.gz \
file://tcl-8.6.12-autopath.patch \
file://tcl-8.6.12-conf.patch \
file://stay-out-of-internals-when-nice-interfaces-are-avail.patch \
file://oops.patch \
file://File-not-found-should-be-ignored-silently.patch \
"

SRC_URI[sha256sum] = "c61f0d6699e2bc7691f119b41963aaa8dc980f23532c4e937739832a5f4a6642"