PV = "4.16.2"

# lazy default so ${@bb.utils.contains(...)} below expands cleanly in
# non-oebridge builds where SERVER_VERSION is otherwise undefined
SERVER_VERSION ??= "openEuler-latest"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply patches from openeuler before poky
# these patches not apply for unsupport arch:
#  dnf-4.10.0-sw.patch 
#  0001-Add-loongarch-architecture-support.patch
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://backport-Fix-bash-completion-due-to-sqlite-changes.patch \
        file://backport-remove-duplicates-when-no-duplicates-exit-with-0.patch \
        file://backport-remove-oldinstallonly-when-no-old-installonly-packages-exit-with-0.patch \
        file://backport-Add-all-candidates-for-reinstall-to-solver.patch \
        file://backport-Limit-queries-to-nevra-forms-when-provided-by-command.patch \
        file://backport-doc-Remove-provide-of-spec-definition-for-repoquery-command.patch \
        file://backport-Update-the-man-page-entry-for-the-countme-option.patch \
        file://backport-Allow-local-downloads-to-same-downloaddir.patch \
        file://backport-Preserve-ACL-when-rotating-logs.patch \
        file://backport-Fix-delta-RPM-wasted-percentage-calculation.patch \
        file://backport-Revert-Unprotect-dnf-and-yum-protect-python3-dnf.patch \
        file://backport-Fix-handling-installonly-packages-reasons.patch \
        file://backport-Add-obsoleters-of-only-latest-versions.patch \
        file://backport-fix-remote-packages-not-copied-to-destdir.patch \
        file://backport-fix-dont-prepend-installroot-to-cachedir-from-commandline.patch \
        file://bugfix-automatic-Use-add_security_filters-not-_update_secur.patch \
        file://add-rpm-transaction-debuginfo.patch \
        file://fix-dnf-history-undo-error-when-history-sqlite-missing.patch \
        file://get-lockfile-exists-before-unlick.patch \
"

# in oee, dnf is a prebuild-tool, so add the following patch when build nativesdk-dnf.
SRC_URI:append:class-nativesdk = " file://0001-dnf-write-the-log-lock-to-root.patch"

# add default repo
SRC_URI:append:class-target = " \
    file://openEuler.repo \
    file://openEulerROS.repo \
"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "329d2d0c8c306d2e0ad3ede8d23c6cb621f5adbdc8bc5cc5d30e2d731d7498bb"

FILES:${PN}:append:class-target = " \
    /etc/yum.repos.d/openEuler.repo \
    ${@bb.utils.contains('DISTRO_FEATURES', 'oe-ros', '/etc/yum.repos.d/openEulerROS.repo', '', d)} \
    "

do_install:append:class-target() {
    mkdir -p ${D}/etc/yum.repos.d/ || echo ""
    local version_dir="${@bb.utils.contains('DISTRO_FEATURES', 'oebridge', '${SERVER_VERSION}', 'openEuler-${DISTRO_VERSION}', d)}"
    sed -i "s/OPENEULER_VER/${version_dir}/g" ${WORKDIR}/openEuler.repo
    cp -f ${WORKDIR}/openEuler.repo ${D}/etc/yum.repos.d/
    cp -f ${WORKDIR}/openEulerROS.repo ${D}/etc/yum.repos.d/
}
