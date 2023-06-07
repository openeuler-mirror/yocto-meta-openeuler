HOMEPAGE = "https://github.com/SELinuxProject"

SRC_URI = "git://github.com/SELinuxProject/selinux.git;branch=master;protocol=https"
SRCREV = "7f600c40bc18d8180993edcd54daf45124736776"

UPSTREAM_CHECK_GITTAGREGEX = "(?P<pver>\d+(\.\d+)+)"

do_compile() {
    oe_runmake all
}

do_install() {
    oe_runmake install \
        DESTDIR="${D}" \
        PREFIX="${prefix}" \
        INCLUDEDIR="${includedir}" \
        LIBDIR="${libdir}" \
        SHLIBDIR="${base_libdir}"
}
