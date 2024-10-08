PV = "4.16.2"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply patches from openeuler before poky
# these patches not apply for unsupport arch:
#  dnf-4.10.0-sw.patch 
#  0001-Add-loongarch-architecture-support.patch
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://add-rpm-transaction-debuginfo.patch \
        file://fix-dnf-history-undo-error-when-history-sqlite-missing.patch \
        file://get-lockfile-exists-before-unlick.patch \
        file://backport-Fix-bash-completion-due-to-sqlite-changes.patch \
        file://backport-remove-duplicates-when-no-duplicates-exit-with-0.patch \
        file://backport-remove-oldinstallonly-when-no-old-installonly-packages-exit-with-0.patch \
        file://backport-Add-all-candidates-for-reinstall-to-solver.patch \
        file://backport-Limit-queries-to-nevra-forms-when-provided-by-command.patch \
        file://backport-doc-Remove-provide-of-spec-definition-for-repoquery-command.patch \
        file://backport-Update-the-man-page-entry-for-the-countme-option.patch \
"

# in oee, dnf is a prebuild-tool, so add the following patch when build nativesdk-dnf.
SRC_URI:append:class-nativesdk = " file://0001-dnf-write-the-log-lock-to-root.patch"

# add default repo
SRC_URI:append:class-target = " \
    file://openEuler.repo \
"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "7de4eb8e85c4d9a74db6f1f827d2dd3348e265631f8678a1dbf7e3346beaad53"

FILES:${PN}:append:class-target = " \
    /etc/yum.repos.d/openEuler.repo \
    "

do_install:append:class-target() {
    mkdir -p ${D}/etc/yum.repos.d/ || echo ""
    local version_dir="openEuler-${DISTRO_VERSION}"
    sed -i "s/OPENEULER_VER/${version_dir}/g" ${WORKDIR}/openEuler.repo
    cp -f ${WORKDIR}/openEuler.repo ${D}/etc/yum.repos.d/
}
