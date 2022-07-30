#main bbfile: yocto-poky/meta/recipes-extended/rpcbind/rpcbind_1.2.5.bb

#version in openEuler
PV = "1.2.6"

S = "${WORKDIR}/${BPN}-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            ${SOURCEFORGE_MIRROR}/rpcbind/rpcbind-${PV}.tar.bz2 \
            file://rpcbind_add_option_to_fix_port_number.patch \
            file://0001-systemd-use-EnvironmentFile.patch \
            "
# files, patches that come from openeuler
# all systemd patches not applied
SRC_URI_prepend += " \
        file://${BPN}-${PV}.tar.bz2 \
        file://rpcbind-0.2.4-runstatdir.patch \
        file://bugfix-rpcbind-GETADDR-return-client-ip.patch \
        file://CVE-2017-8779.patch \
        file://backport-fix-double-free-in-init_transport.patch \
        file://backport-debian-enable-rmt-calls-with-r.patch \
        file://bugfix-listen-tcp-port-111.patch \
        "

# safety: set init.d/rpcbind no permission for other users
do_install_append() {
    chmod 0750 ${D}${sysconfdir}/init.d/rpcbind
}

SRC_URI[tarball.md5sum] = "2d84ebbb7d6fb1fc3566d2d4b37f214b"
SRC_URI[tarball.sha256sum] = "5613746489cae5ae23a443bb85c05a11741a5f12c8f55d2bb5e83b9defeee8de"

# current we not enable sysvint in DISTRO_FEATURES, just use busybox's init, but we want populate_packages_updatercd to work.
# In other word, we want update-rc.d always work when INITSCRIPT_NAME and INITSCRIPT_PARAMS generate with all none systemd scene.
# update-rc.d config form yocto-poky/meta/recipes-extended/rpcbind/rpcbind_1.2.5.bb :
# INITSCRIPT_NAME = "rpcbind"
# INITSCRIPT_PARAMS = "start 12 2 3 4 5 . stop 60 0 1 6 ."
PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'populate_packages_updatercd ', d)}"
