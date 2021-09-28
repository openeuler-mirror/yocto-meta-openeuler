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
	file://group \
	file://inittab \
	file://issue \
	file://issue.net \
	file://LICENSE \
	file://motd \
	file://passwd \
	file://profile \
	file://securetty \
	file://shadow \
	file://sysctl.conf \
	file://rc.functions \
	file://rc.sysinit \
	file://rc.local"

do_install() {
	install -d ${D}/etc
	cp ${WORKDIR}/bashrc  		${D}/etc/
	cp ${WORKDIR}/fstab  		${D}/etc/
	cp ${WORKDIR}/group  		${D}/etc/
	cp ${WORKDIR}/inittab  		${D}/etc/
	cp ${WORKDIR}/issue  		${D}/etc/
	cp ${WORKDIR}/issue.net  	${D}/etc/
	cp ${WORKDIR}/motd		${D}/etc/
	cp ${WORKDIR}/passwd  		${D}/etc/
	cp ${WORKDIR}/profile  		${D}/etc/
	cp ${WORKDIR}/securetty  	${D}/etc/
	cp ${WORKDIR}/shadow  		${D}/etc/
	cp ${WORKDIR}/sysctl.conf  	${D}/etc/
	install -d ${D}/etc/rc.d
	cp ${WORKDIR}/rc.functions  	${D}/etc/rc.d
	cp ${WORKDIR}/rc.sysinit  	${D}/etc/rc.d
	cp ${WORKDIR}/rc.local  	${D}/etc/rc.d
}


FILES_${PN} = "/"
INHIBIT_DEFAULT_DEPS = "1"
