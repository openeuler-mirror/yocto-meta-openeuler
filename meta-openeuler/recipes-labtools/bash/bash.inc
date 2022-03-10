DESCRIPTION = "An sh-compatible command language interpreter."
HOMEPAGE = "http://cnswww.cns.cwru.edu/~chet/bash/bashtop.html"
SECTION = "base/shell"

DEPENDS = "ncurses bison-native"

inherit autotools gettext

EXTRA_OECONF = "--enable-job-control"

ALTERNATIVE_${PN} = "sh"
ALTERNATIVE_LINK_NAME[sh] = "${base_bindir}/sh"
ALTERNATIVE_TARGET[sh] = "${base_bindir}/bash"
ALTERNATIVE_PRIORITY = "100"

export AUTOHEADER = "true"

RDEPENDS_${PN}-ptest += "make"

PARALLEL_MAKE = ""

do_configure () {
    oe_runconf
}

do_configure_prepend () {
    rm -f ${S}/y.tab.c
    if [ ! -e ${S}/acinclude.m4 ]; then
        cat ${S}/aclocal.m4 > ${S}/acinclude.m4
    fi
}

do_compile_ptest () {
    oe_runmake buildtest
}

do_install_append () {
    # Move /usr/bin/bash to /bin/bash, if need
    if [ "${base_bindir}" != "${bindir}" ]; then
        mkdir -p ${D}${base_bindir}
        mv ${D}${bindir}/bash ${D}${base_bindir}
    fi
}

do_install_ptest () {
    make INSTALL_TEST_DIR=${D}${PTEST_PATH}/tests install-test
    cp ${B}/Makefile ${D}${PTEST_PATH}
    sed -i 's/^Makefile/_Makefile/' ${D}${PTEST_PATH}/Makefile
}

pkg_postinst_${PN} () {
    mkdir -p ${sysconfdir}/ || echo ""
    touch ${sysconfdir}/shells
    grep -q "bin/bash" ${sysconfdir}/shells || echo /bin/bash >> ${sysconfdir}/shells
    grep -q "bin/sh" ${sysconfdir}/shells || echo /bin/sh >> ${sysconfdir}/shells
}
FILES_${PN}-dev += "${libdir}/bash/*"
