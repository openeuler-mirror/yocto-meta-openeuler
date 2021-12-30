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
	cp ${WORKDIR}/rc.functions  	${D}/etc/rc.d
	cp ${WORKDIR}/rc.sysinit  	${D}/etc/rc.d
	cp ${WORKDIR}/rc.local  	${D}/etc/rc.d
        install -m 0755 -d ${D}/etc/init.d/
	install -m 0750 ${WORKDIR}/rcS ${D}/etc/init.d/
}

FILES_${PN} = "/"
INHIBIT_DEFAULT_DEPS = "1"
