HOMEPAGE = "https://github.com/SELinuxProject"

# EXTRA_OEMAKE is typically: -e MAKEFLAGS=
# "MAKEFLAGS= " causes problems as ENV variables will not pass to subdirs, so
# we redefine EXTRA_OEMAKE here
EXTRA_OEMAKE = "-e"

# Releases are now from the base of the full tree, necessitating our skipping
# through an extra level of directories.
S = "${WORKDIR}/${BPN}-${PV}"

SELINUX_NAME = "selinux"

COMPONENT = "selinux"

do_compile() {
    oe_runmake all \
        LIBDIR="${libdir}"
}

do_install() {
    oe_runmake install \
        DESTDIR="${D}" \
        PREFIX="${prefix}" \
        INCLUDEDIR="${includedir}" \
        LIBDIR="${libdir}" \
        SHLIBDIR="${base_libdir}" \
        INITDIR="/etc/init.d"
    rm -rf ${D}${libdir}/golang
}
