# this recipe just repack binary from openeuler release
SUMMARY = "Mozilla Firefox Web browser"
DESCRIPTION = "Browser made by mozilla"
HOMEPAGE = "https://www.mozilla.org/firefox/"
LICENSE = "MPL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MPL-2.0;md5=815ca599c9df247a0c7f619bab123dad"

# mime-xdg for desktop file associations
inherit bin_package mime-xdg

# using image mirrors to accelerate downloads
PREMIRRORS:prepend:aarch64 = "\
        https://.*/.* https://mirrors.nju.edu.cn/openeuler/openEuler-24.09/everything/aarch64/Packages/ \
"
PREMIRRORS:prepend:x86-64 = "\
        https://.*/.* https://mirrors.nju.edu.cn/openeuler/openEuler-24.09/everything/x86_64/Packages/ \
"

SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.09/everything/aarch64/Packages/firefox-115.15.0-1.oe2409.aarch64.rpm;name=arm64;subdir=${BP} \
"
SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.09/everything/x86_64/Packages/firefox-115.15.0-1.oe2409.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI[arm64.md5sum] = "eabbe71d4140dc3416cc76452b6b3d0d"
SRC_URI[x86.md5sum] = "864e305c6cbf77541010f14f265c8857"

S = "${WORKDIR}/${BP}"

RDEPENDS:${PN} += "libvpx libwebp ffmpeg dbus-glib nss nspr "

do_install:append() {
    # openeuler embedded shell binary not in usr, fix it
    sed -i "s#/usr/bin/bash#/bin/bash#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/bin/pidof#/bin/pidof#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/sbin/restorecon#/sbin/restorecon#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/bin/sh#/bin/sh#g" ${D}${libdir}/firefox/run-mozilla.sh
}

FILES:${PN} = " \
    /etc/firefox \
    /usr/share \
    ${libdir} \
    ${bindir} \
"
 
# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"
