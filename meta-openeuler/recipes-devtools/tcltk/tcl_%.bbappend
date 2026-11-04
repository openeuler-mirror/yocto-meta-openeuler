# source bb: yocto-meta-openeuler/meta-openeuler/recipes-devtools/tcltk/tcl_8.6.14.bb
PV = "8.6.18"

FILESEXTRAPATHS:prepend := "${THISDIR}/tcl/:"

# source code package name has been changed
# openEuler patch will cause expect compile task failed, so do not patch openEuler patchs
BASE_SRC_URI += " \
            file://${BPN}-core${PV}-src.tar.gz \
"

SRC_URI[sha256sum] = "1880b6337de72431174511419550bb4cf1327b7c8200a5466d1c4eb3ecac5132"

# *.c files, e.g., ${libdir}/tcl8.6/tclAppInit.c should be in ${PN}-dev package
FILES:${PN}-dev += "${libdir}/tcl8.6/*.c"

EXTRA_OECONF += "--with-tzdata=no"

SYSROOT_DIRS += "${bindir}"
