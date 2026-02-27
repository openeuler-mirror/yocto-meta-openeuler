SUMMARY = "Mesa libGL library"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler/mesa"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/mesa-libGL-24.0.3-2.oe2403.aarch64.rpm;name=arm64pkg;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/mesa-libGL-devel-24.0.3-2.oe2403.aarch64.rpm;name=arm64devpkg;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/aarch64/Packages/mesa-libglapi-24.0.3-2.oe2403.aarch64.rpm;name=arm64apipkg;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/mesa-libGL-24.0.3-2.oe2403.x86_64.rpm;name=x86pkg;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/mesa-libGL-devel-24.0.3-2.oe2403.x86_64.rpm;name=x86devpkg;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/OS/x86_64/Packages/mesa-libglapi-24.0.3-2.oe2403.x86_64.rpm;name=x86apipkg;subdir=${BP} \
"


SRC_URI[arm64pkg.md5sum] = "afc6dec8c285928e74e73ad8e576fedd"
SRC_URI[arm64devpkg.md5sum] = "db570a46f63e0f155b51a6e184f9536e"
SRC_URI[arm64apipkg.md5sum] = "ee36badac1692afaf5311fb84a8daabb"

SRC_URI[x86pkg.md5sum] = "4b14029b289e83e94974c3d7c01a2378"
SRC_URI[x86devpkg.md5sum] = "f898d445bbb983b0b202c97be6feca91"
SRC_URI[x86apipkg.md5sum] = "614c2fe82abe909281549f72c2bc2b39"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/lib*.so* \
    ${includedir} \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
