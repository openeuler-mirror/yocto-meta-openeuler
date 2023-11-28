include timezone-append.inc

FILES:tzdata-core:append = " \
        ${datadir}/zoneinfo/Asia/Beijing        \
        ${datadir}/zoneinfo/Asia/Shanghai       \
"

SRC_URI:remove = "file://backport-Much-of-Greenland-still-uses-DST-from-2024-on.patch \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
"

# no need to depends on tzcode-native, as nativesdk-tzcode is included
# zic is in HOSTTOOLS_NOFATAL
DEPENDS:openeuler-prebuilt = ""

do_compile:openeuler-prebuilt () {
        for zone in ${TZONES}; do \
            zic -d ${WORKDIR}${datadir}/zoneinfo -L /dev/null \
                ${S}/${zone} ; \
            zic -d ${WORKDIR}${datadir}/zoneinfo/posix -L /dev/null \
                ${S}/${zone} ; \
            zic -d ${WORKDIR}${datadir}/zoneinfo/right -L ${S}/leapseconds \
                ${S}/${zone} ; \
        done
}

do_install:openeuler-prebuilt() {
	install -d ${D}${datadir}/zoneinfo
# the init code is "cp -pPR ${B}/zoneinfo/* ${D}${datadir}/zoneinfo", but build directory
# is empty and zoneinfo is in "usr/share", so replace ${B}/zoneinfo to ${WORKDIR}/usr/share/zoneinfo
# as workaround
    cp -pPR ${WORKDIR}/usr/share/zoneinfo/* ${D}${datadir}/zoneinfo

	# libc is removing zoneinfo files from package
	cp -pP "${S}/zone.tab" ${D}${datadir}/zoneinfo
	cp -pP "${S}/zone1970.tab" ${D}${datadir}/zoneinfo
	cp -pP "${S}/iso3166.tab" ${D}${datadir}/zoneinfo
	cp -pP "${S}/leapseconds" ${D}${datadir}/zoneinfo
	cp -pP "${S}/leap-seconds.list" ${D}${datadir}/zoneinfo

	# Install default timezone
	if [ -e ${D}${datadir}/zoneinfo/${DEFAULT_TIMEZONE} ]; then
		install -d ${D}${sysconfdir}
		if [ "${INSTALL_TIMEZONE_FILE}" = "1" ]; then
			echo ${DEFAULT_TIMEZONE} > ${D}${sysconfdir}/timezone
		fi
		ln -s ${datadir}/zoneinfo/${DEFAULT_TIMEZONE} ${D}${sysconfdir}/localtime
	else
		bberror "DEFAULT_TIMEZONE is set to an invalid value."
		exit 1
	fi

	chown -R root:root ${D}
}
