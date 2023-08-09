#main bbfile: yocto-poky/meta/recipes-extended/quota/quota_4.06.bb

#version in openEuler
PV = "4.06"

S = "${WORKDIR}/${BPN}-${PV}"

DEPENDS:remove = "dbus"
PACKAGECONFIG:remove = "tcp-wrappers"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            ${SOURCEFORGE_MIRROR}/project/linuxquota/quota-tools/${PV}/quota-${PV}.tar.gz \
            "
# files, patches that come from openeuler
SRC_URI += " \
        file://quota-${PV}.tar.gz \
        file://0000-Limit-number-of-comparison-characters-to-4.patch \
        file://0001-Limit-maximum-of-RPC-port.patch \
        file://0002-quotaio_xfs-Warn-when-large-kernel-timestamps-cannot.patch \
        file://0004-quota_nld-Initialize-sa_mask-when-registering-PID-fi.patch \
        file://0005-quota-nld-fix-open-PID-file-failed-when-systemd-read.patch \
        "

SRC_URI[tarball.md5sum] = "aef94648438832b684978d46fdf75110"
SRC_URI[tarball.sha256sum] = "2f3e03039f378d4f0d97acdb49daf581dcaad64d2e1ddf129495fd579fbd268d"
