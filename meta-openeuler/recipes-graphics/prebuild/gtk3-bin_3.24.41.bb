SUMMARY = "GTK+ graphical user interface library"
DESCRIPTION = ""
HOMEPAGE = "https://gitee.com/src-openeuler/gtk3"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/update/aarch64/Packages/gtk3-3.24.41-2.oe2403.aarch64.rpm;name=arm64;subdir=${BP} \
"

SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/everything/x86_64/Packages/gtk3-3.24.41-1.oe2403.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI:append = " \
        https://repo.openeuler.openatom.cn/openEuler-24.03-LTS/update/aarch64/Packages/gtk3-devel-3.24.41-2.oe2403.aarch64.rpm;name=header;subdir=${BP} \
        "

SRC_URI[arm64.md5sum] = "b014cffc8878c6e96f60e3f746c70c59"
SRC_URI[x86.md5sum] = "f7011785d637da107cc48929af834e44"
SRC_URI[header.md5sum] = "bb582d6092626cc962850b29dea11e0a"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    ${libdir} \
    ${bindir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/libg* \
    ${includedir} \
    /usr/share \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped dev-deps"
