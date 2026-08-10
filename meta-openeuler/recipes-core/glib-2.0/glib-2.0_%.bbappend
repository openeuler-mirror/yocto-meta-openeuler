
OPENEULER_LOCAL_NAME = "glib2"

# openeuler patch
SRC_URI:prepend = " \
        file://glib-${PV}.tar.xz \
"

# remove unneeded patches for version 2.78.3 from poky
SRC_URI:remove = " \
    file://0001-gio-tests-portal-support-Fix-snap-test-ordering-race.patch \
    file://0001-glocalfile-Sum-apparent-size-only-for-files-and-syml.patch \
"

# add more patches for version 2.78.3 from poky
# The following patches cannot be successfully applied to version 2.78.3,
# it causes building error.
# file://0001-Switch-from-the-deprecated-distutils-module-to-the-p.patch
SRC_URI:append = " \
    file://memory-monitor.patch \
    file://fix-regex.patch \
    file://skip-timeout.patch \
"

# add more patches for version 2.78.3 from openEuler
SRC_URI:append = " \
    file://gspawn-eperm.patch \
    file://backport-gmessages-fix-dropping-irrelevant-log-domains.patch \
    file://backport-gutils-Fix-an-unlikely-minor-leak-in-g_build_user_data_dir.patch \
    file://backport-CVE-2024-34397.patch \
    file://backport-gdbusconnection-Allow-name-owners-to-have-the-syntax-of-a-well-known-name.patch \
"

SRC_URI:append:class-native:append = " \
    file://0001-meson.build-do-not-enable-pidfd-features-on-native-g.patch \
"

FILES:${PN}:append = " \
    ${datadir}/glib-2.0/dtds \
"

# fix arm build error: 'errno' undeclared (first use in this function)
SRC_URI:append:arm = " file://0001-fix-compile-error-for-arm32.patch"

PV = "2.78.3"

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

# Add glib-abi-check.c to verify GLib ABI compatibility on target.
# This task is not triggered during normal builds. Run it manually:
#   bitbake glib-2.0 -c do_populate_abi_check
# After execution, the binary is at ${B}/glib-abi-check.
# Copy it to the target and run to check ABI compatibility.
SRC_URI:append = " \
    file://glib-abi-check.c \
"

# Compile glib-abi-check against the installed glib headers and libraries.
# Depends on do_install so that headers and .so are available in ${D}.
do_populate_abi_check(){
    ${CC} ${CFLAGS} ${LDFLAGS} ${WORKDIR}/glib-abi-check.c \
        -o ${B}/glib-abi-check \
        -I${D}${includedir}/glib-2.0 \
        -I${D}${libdir}/glib-2.0/include \
        -L${D}${libdir} \
        -Wl,-rpath,${D}${libdir} \
        -lglib-2.0
}

addtask do_populate_abi_check after do_install

ASSUME_PROVIDE_PKGS = "glib2"
