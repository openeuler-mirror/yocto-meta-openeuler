SUMMARY = "lib-shim-v2 is shim v2 ttrpc client which is called by iSulad."
DESCRIPTION = "Based on Rust programming language, as a shim v2 ttrpc client, it is called by iSulad."
HOMEPAGE = "https://gitee.com/openeuler/lib-shim-v2"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://LIC_NOTE;md5=c7799ac4c617e21866647792dfe9dc8b"

REMOTE_RPM_NAME_aarch64 = "lib-shim-v2-0.0.1-6.oe2203sp2.aarch64.rpm"
REMOTE_RPM_NAME_x86-64 = "lib-shim-v2-0.0.1-6.oe2203sp2.aarch64.rpm"
REMOTE_HEADER_RPM_NAME = "lib-shim-v2-devel-0.0.1-6.oe2203sp2.aarch64.rpm"

SRC_URI[arm64.md5sum] = "55cd6d77172138ed96c06db89408531b"
SRC_URI[x86.md5sum] = "fb1cdaba15faae97c94f9595b09ff945"
SRC_URI[header.md5sum] = "97c8e9fff736e0f96c36dac0e5426aa2"

SRC_URI = " \
        http://repo.openeuler.org/openEuler-22.03-LTS-SP2/OS/aarch64/Packages/lib-shim-v2-0.0.1-6.oe2203sp2.aarch64.rpm;name=arm64 \
        http://repo.openeuler.org/openEuler-22.03-LTS-SP2/OS/x86_64/Packages/lib-shim-v2-0.0.1-6.oe2203sp2.x86_64.rpm;name=x86 \
        http://repo.openeuler.org/openEuler-22.03-LTS-SP2/everything/aarch64/Packages/lib-shim-v2-devel-0.0.1-6.oe2203sp2.aarch64.rpm;name=header \
"

S = "${WORKDIR}/repack"

do_unpack() {
    echo ${LICENSE} > ${OPENEULER_SP_DIR}/lib-shim-v2-bin/LIC_NOTE
    echo ${LICENSE} > ${S}/LIC_NOTE
    cp -f ${OPENEULER_SP_DIR}/lib-shim-v2-bin/${REMOTE_RPM_NAME} ${S}
    cp -f ${OPENEULER_SP_DIR}/lib-shim-v2-bin/${REMOTE_HEADER_RPM_NAME} ${S}
    pushd ${S}
    rpm2cpio ${S}/${REMOTE_RPM_NAME} | cpio -id
    rpm2cpio ${S}/${REMOTE_HEADER_RPM_NAME} | cpio -id
    popd
}

do_compile() {
   pwd 
}

do_install() {
    install -d ${D}${includedir}
    install -m 0644 ${S}/usr/include/* ${D}${includedir}

    install -d ${D}${libdir}
    install -m 0644 ${S}/usr/lib64/* ${D}${libdir}
}

FILES_${PN} = " \
    ${libdir} \
"
 
FILES_${PN}-dev = " \
    ${libdir}/libshim_v2.so.${PV} \
    ${includedir} \
"

INSANE_SKIP_${PN} += "already-stripped"

