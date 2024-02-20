SUMMARY = "lib-shim-v2 is shim v2 ttrpc client which is called by iSulad."
DESCRIPTION = "Based on Rust programming language, as a shim v2 ttrpc client, it is called by iSulad."
HOMEPAGE = "https://gitee.com/openeuler/lib-shim-v2"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-23.09/OS/aarch64/Packages/lib-shim-v2-0.0.1-8.oe2309.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-23.09/OS/x86_64/Packages/lib-shim-v2-0.0.1-8.oe2309.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        https://repo.openeuler.openatom.cn/openEuler-23.09/everything/aarch64/Packages/lib-shim-v2-devel-0.0.1-8.oe2309.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "3bf4618ffba4196a9bdcf3d9ec4e8e83"
SRC_URI[x86.md5sum] = "abf8ad3e5a5516dca86eedc5e585b958"
SRC_URI[header.md5sum] = "cf038d5914510740d4e72f1400d5dbb0"

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
