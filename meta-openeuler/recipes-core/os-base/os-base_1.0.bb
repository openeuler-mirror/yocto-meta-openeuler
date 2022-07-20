SUMMARY = "extra basic configuration files of openEuler Embedded"
DESCRIPTION = "extra basic configuration files as a supplement of poky's base-files bb"
SECTION = "base"
PR = "r1"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

INHIBIT_DEFAULT_DEPS = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# we need updat-rc.d to set up links between init.d and rcX.d
DEPENDS_append = " update-rc.d-native"

SRC_URI = " \
	file://passwd \
	file://group \
	file://sysctl.conf \
	file://rc.functions \
	file://rc.sysinit \
	file://ethertypes \
	file://services \
	file://protocols \
	file://rpc \
"

do_install() {
## the contents of configuration should be changed according features, user configuration etc.

## add config files in /etc folder
	install -d ${D}${sysconfdir}
# passwwd and group refer some settings in base-passwd.bb's src code
	install -m 0644 ${WORKDIR}/group  ${D}${sysconfdir}/
	install -m 0644 ${WORKDIR}/passwd ${D}${sysconfdir}/

# sysctl
	install -m 0600 ${WORKDIR}/sysctl.conf ${D}${sysconfdir}/
# all init scripts should be in /etc/init.d, currently openeuler embedded specific init functions are mainly
# located in rc.functions and rc.sysinit
	install -d ${D}${sysconfdir}/init.d
	install -m 0744 ${WORKDIR}/rc.functions ${D}${sysconfdir}/init.d
	install -m 0744 ${WORKDIR}/rc.sysinit ${D}${sysconfdir}/init.d
# to match busybox's rcS script and buysbox-inittab, set a link in rc5.d to let rc.sysinit run
	if [ x"${INIT_MANAGER}" = x"mdev-busybox" ]; then
		install -d ${D}${sysconfdir}/rc5.d
		update-rc.d -r ${D} rc.sysinit start 50 5 .
	fi

# necessary infrastructure for basic TCP/IP based networking from netbase_6.2.bb
	install -m 0644 ${WORKDIR}/rpc ${D}${sysconfdir}/rpc
	install -m 0644 ${WORKDIR}/protocols ${D}${sysconfdir}/protocols
	install -m 0644 ${WORKDIR}/services ${D}${sysconfdir}/services
	install -m 0644 ${WORKDIR}/ethertypes ${D}${sysconfdir}/ethertypes
}

# architecture/bsp specific configuration, better in architecture/bsp's os-base_%.bbappend
do_install_append_arm() {
       echo "unix" >> ${D}/etc/modules
}

do_install_append_raspberrypi4() {
	sed -i '/\# load kernel modules/imount -o remount,rw \/' ${D}/etc/rc.d/rc.sysinit
}

FILES_${PN} = "/"
