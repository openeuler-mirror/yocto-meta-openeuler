SUMMARY = "extra basic configuration files of openEuler Embedded"
DESCRIPTION = "extra basic configuration files as a supplement of poky's base-files bb"
SECTION = "base"
PR = "r1"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = "file://bashrc \
	file://passwd \
	file://group \
	file://shadow \
	file://sysctl.conf \
	file://rc.functions \
	file://rc.sysinit \
	file://rc.local \
    file://modules \
	file://ethertypes \
	file://services \
	file://protocols \
	file://rpc \
"

do_install() {
## the contents of configuration should be changed according features, user configuration etc.

## add config files in /etc folder
	install -d ${D}${sysconfdir}
	cp ${WORKDIR}/bashrc ${D}${sysconfdir}/
# passwwd and group refer some settings in base-passwd.bb's src code
	install -m 0644 ${WORKDIR}/group  ${D}${sysconfdir}/
	install -m 0644 ${WORKDIR}/passwd ${D}${sysconfdir}/
# \todo shadow needs further configuration
	install -m 0600 ${WORKDIR}/shadow ${D}${sysconfdir}/
# sysctl
	install -m 0600 ${WORKDIR}/sysctl.conf ${D}${sysconfdir}/
# init scripts
	install -d ${D}${sysconfdir}/rc.d
	install -m 0744 ${WORKDIR}/rc.functions ${D}${sysconfdir}/rc.d
	install -m 0744 ${WORKDIR}/rc.sysinit ${D}${sysconfdir}/rc.d
	install -m 0744 ${WORKDIR}/rc.local ${D}${sysconfdir}/rc.d
    install -m 0750 ${WORKDIR}/modules ${D}${sysconfdir}/
	mkdir -p ${D}${sysconfdir}/security/
    touch ${D}${sysconfdir}/security/opasswd
    chmod 600 ${D}${sysconfdir}/security/opasswd

# necessary infrastructure for basic TCP/IP based networking from netbase_6.2.bb
	install -m 0644 ${WORKDIR}/rpc ${D}${sysconfdir}/rpc
	install -m 0644 ${WORKDIR}/protocols ${D}${sysconfdir}/protocols
	install -m 0644 ${WORKDIR}/services ${D}${sysconfdir}/services
	install -m 0644 ${WORKDIR}/ethertypes ${D}${sysconfdir}/ethertypes

# add config file in /var folder
   	mkdir -p ${D}/var/log/
    touch ${D}/var/log/messages ${D}/var/log/lastlog

    mkdir -p ${D}$/lib/modules
    chmod 750 ${D}$/lib/modules
}

# architecture/bsp specific configuration, better in architecture/bsp's os-base_%.bbappend
do_install_append_arm() {
       echo "unix" >> ${D}/etc/modules
}

do_install_append_raspberrypi4() {
	sed -i '/\# load kernel modules/imount -o remount,rw \/' ${D}/etc/rc.d/rc.sysinit
}

PACKAGES =+ "${PN}-sysctl"
FILES_${PN} = "/"
FILES_${PN}-sysctl = "${sysconfdir}/sysctl.conf"
