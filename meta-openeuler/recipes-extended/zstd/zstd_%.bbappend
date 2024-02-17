PV = "1.5.5"

SRC_URI = " \
        file://${BP}.tar.gz \
           "

S = "${WORKDIR}/${BP}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=0822a32f7acdbe013606746641746ee8 \
                    file://COPYING;md5=39bba7d2cf0ba1036f2a6e2be52fe3f0 \
                "

SRC_URI[sha256sum] = "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867"

do_compile:append () {
    oe_runmake ${PACKAGECONFIG_CONFARGS} ZSTD_LEGACY_SUPPORT=${ZSTD_LEGACY_SUPPORT} -C contrib/pzstd
}

do_install:append () {
    oe_runmake install 'DESTDIR=${D}' PREFIX=${prefix} -C contrib/pzstd
}
