PV = "1.5.5"

SRC_URI = " \
        file://${BP}.tar.gz \
           "

S = "${WORKDIR}/${BP}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=0822a32f7acdbe013606746641746ee8 \
                    file://COPYING;md5=39bba7d2cf0ba1036f2a6e2be52fe3f0 \
                "

SRC_URI[sha256sum] = "9c4396cc829cfae319a6e2615202e82aad41372073482fce286fac78646d3ee4"

ZSTD_PZSTD_ENABLED ?= "1"
ZSTD_PZSTD_ENABLED:toolchain-clang:arm:libc-musl = "0"

do_compile () {
    oe_runmake ${PACKAGECONFIG_CONFARGS} ZSTD_LEGACY_SUPPORT=${ZSTD_LEGACY_SUPPORT}
    if [ "${ZSTD_PZSTD_ENABLED}" = "1" ]; then
        oe_runmake ${PACKAGECONFIG_CONFARGS} ZSTD_LEGACY_SUPPORT=${ZSTD_LEGACY_SUPPORT} -C contrib/pzstd
    fi
}

do_install () {
    oe_runmake install 'DESTDIR=${D}'
    if [ "${ZSTD_PZSTD_ENABLED}" = "1" ]; then
        oe_runmake install 'DESTDIR=${D}' PREFIX=${prefix} -C contrib/pzstd
    fi
}
