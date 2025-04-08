# main bbfile: from oe
# http://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-security/audit/audit_3.0.9.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

#version in openEuler
PV = "3.1.2"

S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
# This patches are conflict, not apply:
#  backport-audit-flex-array-workaround.patch
#  backport-audit-undo-flex-array.patch
SRC_URI += " \
        file://${BP}.tar.gz \
        file://bugfix-audit-support-armv7b.patch \
        file://bugfix-audit-userspace-missing-syscalls-for-aarm64.patch \
        file://bugfix-audit-reload-coredump.patch \
        file://audit-Add-sw64-architecture.patch \
        file://backport-Rewrite-legacy-service-functions-in-terms-of-systemc.patch \
        file://backport-Error-out-if-required-zos-parameters-missing.patch \
        file://backport-Fix-deprecated-python-function.patch \
        file://backport-lib-close-audit-socket-in-load_feature_bitmap-334.patch \
        file://backport-lib-enclose-macro-to-avoid-precedence-issues.patch \
        file://backport-memory-allocation-updates-341.patch \
        file://backport-lib-cast-to-unsigned-char-for-character-test-functio.patch \
        file://backport-Make-session-id-consistently-typed-327.patch \
        file://backport-Avoid-file-descriptor-leaks-in-multi-threaded-applic.patch \
        file://backport-first-part-of-NULL-pointer-checks.patch \
        file://backport-second-part-of-NULL-pointer-checks.patch \
        file://backport-last-part-of-NULL-pointer-checks.patch \
        file://backport-Fixed-NULL-checks.patch \
        file://backport-update-error-messages-in-NULL-Checks.patch \
        file://backport-adding-the-file-descriptor-closure.patch \
        file://backport-correcting-memcmp-args-in-check_rule_mismatch-functi.patch \
        file://backport-Use-atomic_int-if-available-for-signal-related-flags.patch \
        file://backport-Use-atomic_uint-if-available-for-signal-related-flag.patch \
        file://backport-avoiding-of-NULL-pointers-dereference-366.patch \
        file://backport-Cleanup-code-in-LRU.patch \
        file://backport-Fix-memory-leaks.patch \
        file://backport-fix-one-more-leak.patch \
        file://auditd.conf \
        file://audit.rules \
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

ASSUME_PROVIDE_PKGS = "audit-libs"
