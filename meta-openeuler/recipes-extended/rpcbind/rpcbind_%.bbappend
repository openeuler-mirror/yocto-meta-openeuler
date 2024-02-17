#main bbfile: yocto-poky/meta/recipes-extended/rpcbind/rpcbind_1.2.5.bb

#version in openEuler
PV = "1.2.6"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# files, patches that come from openeuler
# all openeuler systemd patches can't apply, include rpcbind-0.2.4-runstatdir.patch
# backport-debian-enable-rmt-calls-with-r.patch is conflict
SRC_URI:append = " \
        file://${BP}.tar.bz2 \
        file://bugfix-rpcbind-GETADDR-return-client-ip.patch \
        file://fix-CVE-2017-8779.patch \
        file://backport-fix-double-free-in-init_transport.patch \
        file://bugfix-listen-tcp-port-111.patch \
        "
# safety: set init.d/rpcbind no permission for other users
do_install:append() {
    chmod 0750 ${D}${sysconfdir}/init.d/rpcbind
}

SRC_URI[tarball.md5sum] = "2d84ebbb7d6fb1fc3566d2d4b37f214b"
SRC_URI[tarball.sha256sum] = "5613746489cae5ae23a443bb85c05a11741a5f12c8f55d2bb5e83b9defeee8de"

# we current use rc5.d of rcS, in normal mode we don't want it autostart default for security
INITSCRIPT_PARAMS = "start 12 2 3 4 . stop 60 0 1 6 ."
