# main bbfile: yocto-poky/meta/recipes-extended/logrotate/logrotate_3.18.0.bb

# version in openEuler
PV = "3.21.0"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://backport-do-not-rotate-old-logs-on-prerotate-failure.patch \
"


# ref oe-core logrotate-3.21.0.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://run-ptest"

inherit ptest

do_install:append() {
    # don't create logrotate.status, ref oe-core logrotate-3.21.0
    rm ${D}${localstatedir}/lib/logrotate.status
}

do_install_ptest() {
    cp -r ${S}/test/* ${D}${PTEST_PATH}
    cp ${S}/test-driver ${D}${PTEST_PATH}
    cp ${B}/test/Makefile ${D}${PTEST_PATH}

    # Do not rebuild Makefile
    sed -i 's/^Makefile:/_Makefile:/' ${D}${PTEST_PATH}/Makefile

    # Fix top_builddir and top_srcdir
    sed -e 's/^top_builddir = \(.*\)/top_builddir = ./' \
        -e 's/^top_srcdir = \(.*\)/top_srcdir = ./' \
        -i ${D}${PTEST_PATH}/Makefile

    # Replace bash with sh
    sed -i 's,/bin/bash,/bin/sh,' ${D}${PTEST_PATH}/Makefile

    # Replace gawk with awk
    sed -i 's/gawk/awk/' ${D}${PTEST_PATH}/Makefile
    ln -s ${sbindir}/logrotate ${D}${PTEST_PATH}
}

# coreutils is needed to have "readlink"
RDEPENDS:${PN}-ptest += "make coreutils"
