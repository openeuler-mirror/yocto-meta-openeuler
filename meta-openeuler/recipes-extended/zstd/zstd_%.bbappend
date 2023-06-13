PV = "1.5.0"

SRC_URI = " \
        file://${BPN}-${PV}.tar.gz \
        file://backport-0001-CVE-2022-4899.patch \
        file://backport-0002-CVE-2022-4899.patch \
           "

S = "${WORKDIR}/${BP}"
SRC_URI[sha256sum] = "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867"

do_compile_append () {
    oe_runmake ${PACKAGECONFIG_CONFARGS} ZSTD_LEGACY_SUPPORT=${ZSTD_LEGACY_SUPPORT} -C contrib/pzstd
}

do_install_append () {
    oe_runmake install 'DESTDIR=${D}' PREFIX=${prefix} -C contrib/pzstd
}
