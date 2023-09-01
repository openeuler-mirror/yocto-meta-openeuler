# main bbfile: from oe
# http://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-security/audit/audit_3.0.9.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

#version in openEuler
PV = "3.1.1"

S = "${WORKDIR}/audit-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        "

# files, patches that come from openeuler
# This patches are conflict, not apply:
#  backport-audit-flex-array-workaround.patch
#  backport-audit-undo-flex-array.patch
SRC_URI += " \
        file://audit-${PV}.tar.gz \
        file://bugfix-audit-support-armv7b.patch \
        file://bugfix-audit-userspace-missing-syscalls-for-aarm64.patch \
        file://bugfix-audit-reload-coredump.patch \
        file://audit-Add-sw64-architecture.patch \
        file://auditd.conf \
        file://audit.rules \
        file://backport-auditswig.i-avoid-setter-generation-for-audit_rule_d.patch \
        "

# we don't want audit python3 runtime tool
DEPENDS:remove = " python3 "
EXTRA_OECONF:remove = " --with-python3=yes "
EXTRA_OECONF += " --with-python3=no "
PACKAGES:remove = " ${PN}-python "
FILES:${PN}-python:remove = " ${libdir}/python${PYTHON_BASEVERSION} "
FILES:auditd += " ${libdir} "

# use openeuler's config and rules
do_install:append() {
	cp ${WORKDIR}/audit.rules ${D}/etc/audit/rules.d/audit.rules
	cp ${WORKDIR}/audit.rules ${D}/etc/audit/audit.rules
	cp ${WORKDIR}/auditd.conf ${D}/etc/audit/auditd.conf
	rm -rf ${D}/${libdir}/pkgconfig
}

do_install:append:arm() {
    sed -i "/arch=b64/d" ${D}/etc/audit/audit.rules
}
