SUMMARY = "lib-shim-v2 is shim v2 ttrpc client which is called by iSulad."
DESCRIPTION = "Based on Rust programming language, as a shim v2 ttrpc client, it is called by iSulad."
HOMEPAGE = "https://gitee.com/openeuler/lib-shim-v2"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        http://repo.openeuler.openatom.cn/openEuler-22.03-LTS-SP2/OS/aarch64/Packages/lib-shim-v2-0.0.1-6.oe2203sp2.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        http://repo.openeuler.openatom.cn/openEuler-22.03-LTS-SP2/OS/x86_64/Packages/lib-shim-v2-0.0.1-6.oe2203sp2.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        http://repo.openeuler.openatom.cn/openEuler-22.03-LTS-SP2/everything/aarch64/Packages/lib-shim-v2-devel-0.0.1-6.oe2203sp2.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "55cd6d77172138ed96c06db89408531b"
SRC_URI[x86.md5sum] = "fb1cdaba15faae97c94f9595b09ff945"
SRC_URI[header.md5sum] = "97c8e9fff736e0f96c36dac0e5426aa2"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libshim_v2.so.${PV} \
    ${includedir} \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
