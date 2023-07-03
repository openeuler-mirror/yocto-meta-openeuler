PV = "4.14.0"

OPENEULER_BRANCH = "master"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# delete useless codes from poky
SRC_URI:remove = "git://github.com/rpm-software-management/dnf.git;branch=master;protocol=https \
"

# apply patches from openeuler before poky
SRC_URI:prepend = " \
        https://github.com/rpm-software-management/dnf/archive/${PV}/${BPN}-${PV}.tar.gz \
        file://unlock-pidfile-if-current-proccess-is-NOT-dnf.patch \
        file://fix-pid-file-residue.patch \
        file://add-rpm-transaction-debuginfo.patch \
        file://adapt-test-another-process.patch \
        file://fix-dnf-history-undo-error-when-history-sqlite-missing.patch \
        file://dnf-4.10.0-sw.patch \
"

# add default repo
SRC_URI += " \
    file://openEuler.repo \
"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "7de4eb8e85c4d9a74db6f1f827d2dd3348e265631f8678a1dbf7e3346beaad53"

FILES:${PN} += " \
    /etc/yum.repos.d/openEuler.repo \
    "

do_install:append() {
    mkdir -p ${D}/etc/yum.repos.d/ || echo ""
    local version_dir="openEuler-${DISTRO_VERSION}"
    sed -i "s/OPENEULER_VER/${version_dir}/g" ${WORKDIR}/openEuler.repo
    cp -f ${WORKDIR}/openEuler.repo ${D}/etc/yum.repos.d/
}
