SUMMARY = "SysV init scripts"
HOMEPAGE = "https://github.com/fedora-sysv/initscripts"
DESCRIPTION = "Initscripts provide the basic system startup initialization scripts for the system.  These scripts include actions such as filesystem mounting, fsck, RTC manipulation and other actions routinely performed at system startup.  In addition, the scripts are also used during system shutdown to reverse the actions performed at startup."
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"
PR = "1"

SRC_URI = "file://initscripts/initscripts-10.12.tar.gz \
           file://initscripts/backport-run-ifdown-on-all-interfaces.patch \
           file://initscripts/bugfix-initscripts-add-udev-wait-dependency-for-network.patch \
           file://initscripts/bugfix-mod-network-function-when-NM-unmanage-devices.patch \
           file://initscripts/bugfix-initscripts-set-PERSISTENT_DHCLIENT-default-to-yes.patch \
           file://initscripts/bugfix-network-need-chkconfig-on.patch \
           file://initscripts/bugfix-restart-network-warning.patch \
           file://initscripts/new-network-fork-to-start-dhcp.patch \
           file://initscripts/exec-udevadm-settle-when-network-start.patch \
           file://initscripts/remove-rename_device_lock-when-process-does-not-exis.patch \
"
INHIBIT_DEFAULT_DEPS = "1"

KERNEL_VERSION = ""

DEPENDS_append = " update-rc.d-native"
PACKAGE_WRITE_DEPS_append = " ${@bb.utils.contains('DISTRO_FEATURES','systemd','systemd-systemctl-native','',d)}"

PACKAGES =+ "${PN}-functions ${PN}-sushell"
RDEPENDS_${PN} = "initd-functions \
                  ${@bb.utils.contains('DISTRO_FEATURES','selinux','${PN}-sushell','',d)} \
		 "
#Recommend pn-functions so that it will be a preferred default provider for initd-functions
RRECOMMENDS_${PN} = "${PN}-functions"
RPROVIDES_${PN}-functions = "initd-functions"
RCONFLICTS_${PN}-functions = "lsbinitscripts"
FILES_${PN}-functions = "${sysconfdir}/init.d/functions*"
FILES_${PN}-sushell = "{base_sbindir}/sushell"

HALTARGS ?= "-d -f"

do_configure() {
}

do_install () {
#
# Create directories and install device independent scripts
#
        mkdir -p ${D}/etc/sysconfig/network-scripts
        install ${S}/network-scripts/* ${D}/etc/sysconfig/network-scripts/ 

        mkdir -p ${D}/etc/init.d
        install ${S}/etc/rc.d/init.d/* ${D}/etc/init.d/
}

MASKED_SCRIPTS = ""

pkg_postinst_${PN} () {
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		if [ -n "$D" ]; then
			OPTS="--root=$D"
		fi
		for SERVICE in ${MASKED_SCRIPTS}; do
			systemctl $OPTS mask $SERVICE.service
		done
	fi

    # Delete any old volatile cache script, as directories may have moved
    if [ -z "$D" ]; then
        rm -f "/etc/volatile.cache"
    fi
}

do_configure[noexec] = "1"
do_compile[noexec] = "1"

CONFFILES_${PN} += "${sysconfdir}/init.d/checkroot.sh"
