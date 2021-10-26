SUMMARY = "gnu-configize"
DESCRIPTION = "Tool that installs the GNU config.guess / config.sub into a directory tree"
SECTION = "devel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
 
DEPENDS_class-native = "hostperl-runtime-native"

INHIBIT_DEFAULT_DEPS = "1"

PR = "r0"

SRC_URI =  " \
           file://gnu-configize.in \
           file://config.guess \
           file://config.sub \
	   "

SRC_URI[md5sum] = "cdb56e9968c9a3674fe4ad8880665f78"
SRC_URI[sha256sum] = "b48543f72d717a8c07cf3b995175b3293c24dac9c9efad01b312321c0c809f07"

do_compile() {
	:
}

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
	install -d ${D}${datadir}/gnu-config \
		   ${D}${bindir}
	cat ${WORKDIR}/gnu-configize.in | \
		sed -e 's,@gnu-configdir@,${datadir}/gnu-config,g' \
		    -e 's,@autom4te_perllibdir@,/usr/share/autoconf,g' > ${D}${bindir}/gnu-configize
	# In the native case we want the system perl as perl-native can't have built yet
	if [ "${PN}" != "gnu-config-native" -a "${PN}" != "nativesdk-gnu-config" ]; then
		sed -i -e 's,/usr/bin/env,${bindir}/env,g' ${D}${bindir}/gnu-configize
	fi
	chmod 500 ${D}${bindir}/gnu-configize
	install -m 0644 "${WORKDIR}/config.guess" ${D}${datadir}/gnu-config/
	install -m 0644 "${WORKDIR}/config.sub" ${D}${datadir}/gnu-config/
	
}

PACKAGES = "${PN}"
FILES_${PN} = "${bindir} ${datadir}/gnu-config"

BBCLASSEXTEND = "native nativesdk"
