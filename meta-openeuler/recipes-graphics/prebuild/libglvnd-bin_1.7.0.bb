SUMMARY = "OpenGL support for libglvnd"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/libglvnd-opengl-1.7.0-1.oe2403.aarch64.rpm;name=arm64;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/libglvnd-1.7.0-1.oe2403.aarch64.rpm;name=arm64-2;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/libglvnd-devel-1.7.0-1.oe2403.aarch64.rpm;name=arm64-3;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/libglvnd-glx-1.7.0-1.oe2403.aarch64.rpm;name=arm64-4;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/everything/x86_64/Packages/libglvnd-opengl-1.7.0-1.oe2403.x86_64.rpm;name=x86;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/libglvnd-1.7.0-1.oe2403.x86_64.rpm;name=x86-2;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/libglvnd-devel-1.7.0-1.oe2403.x86_64.rpm;name=x86-3;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/libglvnd-glx-1.7.0-1.oe2403.x86_64.rpm;name=x86-4;subdir=${BP} \
"

SRC_URI:append = " \
        "

SRC_URI[arm64.md5sum] = "21d350e8923572cb3cedf6fd37f3dc0f"
SRC_URI[arm64-2.md5sum] = "02a239aab023cd0a16fff40c50c56e43"
SRC_URI[arm64-3.md5sum] = "4dc6efa4b78c73a6291c9010c16ce785"
SRC_URI[arm64-4.md5sum] = "44af6b4b421866eb47799f5e99944c27"

SRC_URI[x86.md5sum] = "3b994343335b537b362867f3217af99b"
SRC_URI[x86-2.md5sum] = "77793e68c696f1258d1e5506dbfc596c"
SRC_URI[x86-3.md5sum] = "9f82c51b0b9e0c0b6aeb593ef3615b88"
SRC_URI[x86-4.md5sum] = "b8c60e0ddb1beb0960b5afd34e69dbae"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libOpenGL.so* \
    ${libdir}/libGLdispatch.so* \
    ${libdir}/lib*.so* \
    ${includedir} \
    /usr/share \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
