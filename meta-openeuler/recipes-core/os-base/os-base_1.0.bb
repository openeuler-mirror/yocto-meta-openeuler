SUMMARY = "OS basic configuration files"
DESCRIPTION = "base files"
SECTION = "base"
PR = "r1"
LICENSE = "CLOSED"

FILESPATH = "${THISDIR}/${BPN}/"
DL_DIR = "${THISDIR}/${BPN}/"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

SRC_URI = "file://bashrc \
	file://fstab \
	file://rcS \
	file://group \
	file://inittab \
	file://issue \
	file://issue.net \
	file://LICENSE \
	file://motd \
	file://passwd \
	file://profile \
	file://shadow \
	file://sysctl.conf \
	file://rc.functions \
	file://rc.sysinit \
	file://rc.local"

hostname = "openeuler"

do_install() {
	install -d ${D}/etc
	cp ${WORKDIR}/bashrc  		${D}/etc/
	install -m 0600 ${WORKDIR}/fstab ${D}/etc/
	cp ${WORKDIR}/group  		${D}/etc/
	cp ${WORKDIR}/inittab  		${D}/etc/
	cp ${WORKDIR}/issue  		${D}/etc/
	cp ${WORKDIR}/issue.net  	${D}/etc/
	cp ${WORKDIR}/motd		${D}/etc/
	cp ${WORKDIR}/passwd  		${D}/etc/
	cp ${WORKDIR}/profile  		${D}/etc/
	install -m 0600 ${WORKDIR}/shadow ${D}/etc/
	install -m 0600 ${WORKDIR}/sysctl.conf ${D}/etc/
	install -d ${D}/etc/rc.d
	install -m 0744 ${WORKDIR}/rc.functions ${D}/etc/rc.d
	install -m 0744 ${WORKDIR}/rc.sysinit ${D}/etc/rc.d
	install -m 0744 ${WORKDIR}/rc.local ${D}/etc/rc.d
        install -m 0755 -d ${D}/etc/init.d/
	install -m 0750 ${WORKDIR}/rcS ${D}/etc/init.d/
        mkdir -p ${D}/var/log/
        touch ${D}/var/log/messages ${D}/var/log/lastlog
        mkdir -p ${D}/var/run/faillock ${D}/tmp
        mkdir -p ${D}/proc ${D}/sys ${D}/root ${D}/dev ${D}/sys/fs/cgroup
        mkdir -p ${D}/var/log/audit ${D}/var/run/sshd
        if [ "${hostname}" ]; then
            echo ${hostname} > ${D}${sysconfdir}/hostname
            echo "127.0.1.1 ${hostname}" >> ${D}${sysconfdir}/hosts
        fi
        mkdir -p ${D}${sysconfdir}/security/
        touch ${D}${sysconfdir}/security/opasswd
        chmod 600 ${D}${sysconfdir}/security/opasswd
}

do_install_append_arm() {
	echo "insmod /lib/modules/5.10.0/kernel/net/unix/unix.ko" >> ${D}/etc/rc.d/rc.local
}

do_install_append_raspberrypi4() {
	sed -i 's/ttyAMA0/ttyS0/g' ${D}/etc/inittab
	sed -i '/\# load kernel modules/imount -o remount,rw \/' ${D}/etc/rc.d/rc.sysinit
}

PACKAGES =+ "${PN}-sysctl"
FILES_${PN} = "/"
FILES_${PN}-sysctl = "${sysconfdir}/sysctl.conf"
INHIBIT_DEFAULT_DEPS = "1"
