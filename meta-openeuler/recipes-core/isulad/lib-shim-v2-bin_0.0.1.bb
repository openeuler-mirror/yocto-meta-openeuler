SUMMARY = "lib-shim-v2 is shim v2 ttrpc client which is called by iSulad."
DESCRIPTION = "Based on Rust programming language, as a shim v2 ttrpc client, it is called by iSulad."
HOMEPAGE = "https://gitee.com/openeuler/lib-shim-v2"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS-SP4/OS/aarch64/Packages/lib-shim-v2-0.0.1-12.oe2403sp4.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS-SP4/OS/x86_64/Packages/lib-shim-v2-0.0.1-12.oe2403sp4.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS-SP4/everything/aarch64/Packages/lib-shim-v2-devel-0.0.1-12.oe2403sp4.aarch64.rpm;name=header_arm;subdir=${BP} \
        "

SRC_URI:append:x86-64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS-SP4/everything/x86_64/Packages/lib-shim-v2-devel-0.0.1-12.oe2403sp4.x86_64.rpm;name=header_x86;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "589b902ed51d095ecf0dfb5b8337e8ea"
SRC_URI[x86.md5sum] = "14258e15b3ac8f3ac8749ad2fd1f6274"
SRC_URI[header_arm.md5sum] = "6ec6032aeaea490f1944a89df17e1b1b"
SRC_URI[header_x86.md5sum] = "8e777848b7472823b44367458ec4b372"

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
