SUMMARY = "A cross-platform multimedia library"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.oepkgs.net/openeuler/rpm/openEuler-24.03-LTS/extras/aarch64/Packages/g/glfw-3.3.2-2.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.oepkgs.net/openeuler/rpm/openEuler-24.03-LTS/extras/x86_64/Packages/g/glfw-3.3.2-2.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        https://repo.oepkgs.net/openeuler/rpm/openEuler-24.03-LTS/extras/aarch64/Packages/g/glfw-devel-3.3.2-2.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "98cc6fabb8567816d260a82f3f2db3fb"
SRC_URI[x86.md5sum] = "5c4e0ef750c8ec6af5dc9ca68b34fcd9"
SRC_URI[header.md5sum] = "8fc1d7c84388f3b3911709a42898a4d8"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libglfw.so* \
    ${libdir}/*.so* \
    ${includedir} \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
