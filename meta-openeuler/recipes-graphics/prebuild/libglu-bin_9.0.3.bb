SUMMARY = "Mesa libGLU library"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler/mesa-libGLU"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/mesa-libGLU-9.0.3-1.oe2403.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/mesa-libGLU-9.0.3-1.oe2403.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/everything/aarch64/Packages/mesa-libGLU-devel-9.0.3-1.oe2403.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "3cf42d0d6c59793e20aca93a55066e5e"
SRC_URI[x86.md5sum] = "540e864fbc0d7f9fa44999ccd001881e"
SRC_URI[header.md5sum] = "6bb64da8c1f4828d7af9431ff0a90894"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libGLU.so* \
    ${includedir} \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
