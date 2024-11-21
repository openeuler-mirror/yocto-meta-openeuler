# source bb: yocto-meta-openeuler/meta-openeuler/recipes-devtools/tcltk/tcl_8.6.14.bb
PV = "8.6.14"

FILESEXTRAPATHS:prepend := "${THISDIR}/tcl/:"

# source code package name has been changed
# openEuler patch will cause expect compile task failed, so do not patch openEuler patchs
BASE_SRC_URI += " \
            file://${BPN}-core${PV}-src.tar.gz \
"

SRC_URI[sha256sum] = "ff604f43862a778827d7ecd1ad7686950ac2ef48d9cf69d3424cea9de08d9a72"

# *.c files, e.g., ${libdir}/tcl8.6/tclAppInit.c should be in ${PN}-dev package
FILES:${PN}-dev += "${libdir}/tcl8.6/*.c"

EXTRA_OECONF += "--with-tzdata=no"

SYSROOT_DIRS += "${bindir}"
