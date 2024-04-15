# source bb: meta/recipes-devtools/tcltk/tcl_8.6.11.bb
PV = "8.6.14"

FILESEXTRAPATHS:prepend := "${THISDIR}/tcl/:"

# fix_issue_with_old_distro_glibc.patch only needs to be used when built on glibc older than 2.14
# fix_non_native_build_issue.patch cannot be applied
SRC_URI:remove = " \
            file://fix_non_native_build_issue.patch \
            file://fix_issue_with_old_distro_glibc.patch \
    "

# source code package name has been changed
# openEuler patch will cause expect compile task failed, so do not patch openEuler patchs
BASE_SRC_URI += " \
            file://${BPN}-core${PV}-src.tar.gz \
"

SRC_URI[sha256sum] = "ff604f43862a778827d7ecd1ad7686950ac2ef48d9cf69d3424cea9de08d9a72"

# *.c files, e.g., ${libdir}/tcl8.6/tclAppInit.c should be in ${PN}-dev package
FILES:${PN}-dev += "${libdir}/tcl8.6/*.c"

EXTRA_OECONF += "--with-tzdata=no"
