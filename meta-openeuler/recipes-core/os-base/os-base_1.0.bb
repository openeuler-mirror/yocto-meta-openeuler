SUMMARY = "OS basic configuration files"
DESCRIPTION = "base files"
SECTION = "base"
PR = "r1"
LICENSE = "MulanPSL-2.0"


LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

SRC_URI = "file://${WORKDIR}/bashrc \
	file://${WORKDIR}/fstab \
	file://${WORKDIR}/group \
	file://${WORKDIR}/inittab \
	file://${WORKDIR}/issue \
	file://${WORKDIR}/issue.net \
	file://${WORKDIR}/LICENSE \
	file://${WORKDIR}/login.defs \
	file://${WORKDIR}/motd \
	file://${WORKDIR}/passwd \
	file://${WORKDIR}/profile \
	file://${WORKDIR}/securetty \
	file://${WORKDIR}/shadow \
	file://${WORKDIR}/sysctl.conf"

do_install() {
	install -d ${D}/etc
	cp ${WORKDIR}/bashrc  		${D}/etc/
	cp ${WORKDIR}/fstab  		${D}/etc/
	cp ${WORKDIR}/group  		${D}/etc/
	cp ${WORKDIR}/inittab  		${D}/etc/
	cp ${WORKDIR}/issue  		${D}/etc/
	cp ${WORKDIR}/issue.net  	${D}/etc/
	cp ${WORKDIR}/login.defs  	${D}/etc/
	cp ${WORKDIR}/motd  		${D}/etc/
	cp ${WORKDIR}/passwd  		${D}/etc/
	cp ${WORKDIR}/profile  		${D}/etc/
	cp ${WORKDIR}/securetty  	${D}/etc/
	cp ${WORKDIR}/shadow  		${D}/etc/
	cp ${WORKDIR}/sysctl.conf  	${D}/etc/
}


FILES_${PN} = "/"
