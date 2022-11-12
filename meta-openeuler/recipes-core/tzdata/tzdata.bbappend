include timezone-append.inc

FILES_tzdata-core_append += " \
        ${datadir}/zoneinfo/Asia/Beijing        \
        ${datadir}/zoneinfo/Asia/Shanghai       \
"

# no need to depends on tzcode-native, as nativesdk-tzcode is included
# zic is in HOSTTOOLS_NOFATAL
DEPENDS = ""

do_compile () {
        for zone in ${TZONES}; do \
            zic -d ${WORKDIR}${datadir}/zoneinfo -L /dev/null \
                ${S}/${zone} ; \
            zic -d ${WORKDIR}${datadir}/zoneinfo/posix -L /dev/null \
                ${S}/${zone} ; \
            zic -d ${WORKDIR}${datadir}/zoneinfo/right -L ${S}/leapseconds \
                ${S}/${zone} ; \
        done
}
