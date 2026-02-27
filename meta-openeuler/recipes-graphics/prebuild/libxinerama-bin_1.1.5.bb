SUMMARY = "X.Org X11 libXinerama runtime library"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler/libXinerama"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/libXinerama-1.1.5-1.oe2403.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/everything/x86_64/Packages/libXinerama-1.1.5-1.oe2403.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/everything/aarch64/Packages/libXinerama-devel-1.1.5-1.oe2403.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "d9b42c4e13053b2f32285248dda81402"
SRC_URI[x86.md5sum] = "ba478d2693f33c7d72ddd0257957dd9f"
SRC_URI[header.md5sum] = "ac5f0c17876cf3ed5d2bda2eb709c607"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libXinerama.so* \
    ${includedir} \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
