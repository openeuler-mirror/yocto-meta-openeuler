SUMMARY = "Tool suite for app installation and deployment"
DESCRIPTION = "oeDeploy"
HOMEPAGE = "https://gitee.com/openeuler/oeDeploy"

PV = "1.1.1"

SRC_URI += " \
   file://oedp-${PV}.tar.gz \
   "

do_compile[noexec] = "1"

LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

RDEPENDS:${PN} += "python3 python3-ansible python3-prettytable python3-netaddr"

S = "${WORKDIR}/oedp-${PV}"

do_install() {
    install -d ${D}${nonarch_libdir}/oedp/
    install -d ${D}${datadir}/applications
    install -d ${D}${sysconfdir}/oedp/config/
    install -d ${D}${bindir}

    cp -rdpf ${S}/src ${D}${nonarch_libdir}/oedp/

    chown -R root:root ${D}${nonarch_libdir}/oedp/
    chmod -R 700 ${D}${nonarch_libdir}/oedp/

    mv -f ${D}${nonarch_libdir}/oedp/src/config/* ${D}${sysconfdir}/oedp/config/
    install -d ${D}${sysconfdir}/oedp/config/repo/cache
    install -c -m 0400 ${S}/static/* ${D}${datadir}/applications/
    install -c -m 0500 ${S}/oedp.py ${D}${bindir}/oedp

    install -d ${D}${localstatedir}/oedp/log
    install -d ${D}${localstatedir}/oedp/plugin
    install -d ${D}${localstatedir}/oedp/python
    install -d ${D}${localstatedir}/oedp/python/venv
}

FILES:${PN} += "${nonarch_libdir}/oedp/ ${datadir}/applications ${sysconfdir}/oedp ${bindir}"
# INSANE_SKIP:${PN} += "already-stripped"
