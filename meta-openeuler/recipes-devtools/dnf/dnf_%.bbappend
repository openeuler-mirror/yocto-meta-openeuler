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
"

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
