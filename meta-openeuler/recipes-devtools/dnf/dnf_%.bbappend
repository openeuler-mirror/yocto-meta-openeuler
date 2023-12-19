PV = "4.14.0"

# find patches under openeuler at firse
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# delete useless codes from poky
SRC_URI_remove = " \
    git://github.com/rpm-software-management/dnf.git;branch=master;protocol=https \
"

# apply patches from openeuler before poky
SRC_URI_append = " \
    file://${BP}.tar.gz \
    file://add-rpm-transaction-debuginfo.patch \
    file://fix-dnf-history-undo-error-when-history-sqlite-missing.patch \
    file://backport-fix-plugins-unit-tests-unload-plugins-upon-their-deletion.patch \
    file://backport-pass-whole-url-in-relativeUrl-to-packageTarget-for-rpm-url-download.patch \
    file://backport-add-support-for-rollback-of-group-upgrade-rollback.patch \
    file://backport-ignore-processing-variable-files-with-unsupported-encoding.patch \
    file://backport-fix-AttributeError-when-IO-busy-and-press-ctrl-c.patch \
    file://backport-Add-provide-exception-handling.patch \
"

# add default repo
SRC_URI_append = " \
    file://openEuler.repo \
"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "7de4eb8e85c4d9a74db6f1f827d2dd3348e265631f8678a1dbf7e3346beaad53"

FILES_${PN} += " \
    /etc/yum.repos.d/openEuler.repo \
    "

do_install_append() {
    mkdir -p ${D}/etc/yum.repos.d/ || echo ""
    local version_dir="openEuler-${DISTRO_VERSION}"
    sed -i "s/OPENEULER_VER/${version_dir}/g" ${WORKDIR}/openEuler.repo
    cp -f ${WORKDIR}/openEuler.repo ${D}/etc/yum.repos.d/
}
