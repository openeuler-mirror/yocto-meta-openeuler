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

# use libstdc%2B%2B-12.3.1-37.oe2409.aarch64.rpm is a  workaround for arm64 c++ library incompatible issue.
SRC_URI:aarch64 = " \
        https://repo.openeuler.openatom.cn/openEuler-24.09/everything/aarch64/Packages/firefox-115.15.0-1.oe2409.aarch64.rpm;name=arm64;subdir=${BP} \
        https://repo.openeuler.openatom.cn/openEuler-24.09/everything/aarch64/Packages/libstdc%2B%2B-12.3.1-37.oe2409.aarch64.rpm;name=arm64-cxx;subdir=libstdcxx-bin \
"
SRC_URI:x86-64 =  " \
        https://repo.openeuler.openatom.cn/openEuler-24.09/everything/x86_64/Packages/firefox-115.15.0-1.oe2409.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI[arm64.md5sum] = "eabbe71d4140dc3416cc76452b6b3d0d"
SRC_URI[x86.md5sum] = "864e305c6cbf77541010f14f265c8857"
SRC_URI[arm64-cxx.md5sum] = "eebb9ca9e41b804c11ded7f3b5c4891b"

S = "${WORKDIR}/${BP}"

RDEPENDS:${PN} += "libvpx libwebp ffmpeg dbus-glib nss nspr "

do_install:append() {
    # openeuler embedded shell binary not in usr, fix it
    sed -i "s#/usr/bin/bash#/bin/bash#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/bin/pidof#/bin/pidof#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/sbin/restorecon#/sbin/restorecon#g" ${D}/usr/bin/firefox
    sed -i "s#/usr/bin/sh#/bin/sh#g" ${D}${libdir}/firefox/run-mozilla.sh

    # workaround for arm64 c++ library incompatible issue.
    if [ -f ${WORKDIR}/libstdcxx-bin/usr/lib64/libstdc++.so.6.0.30 ];then
        install -m 0755 ${WORKDIR}/libstdcxx-bin/usr/lib64/libstdc++.so.6.0.30 ${D}${libdir}/firefox/libstdc++.so.6
    fi
}

# workaround for arm64 c++ library incompatible issue.
PRIVATE_LIBS:aarch64 = "libstdc++.so.6"

FILES:${PN} = " \
    /etc/firefox \
    /usr/share \
    ${libdir} \
    ${bindir} \
"
 
# don't need '/etc/ima'
# file-rdeps: this recipe repacks openEuler's firefox RPM. Its ELF binaries
# (firefox, vaapitest, libxul.so) NEEDED many GUI/X11/alsa/freetype/fontconfig
# libs that are NOT Yocto-provided — they are pulled as openEuler RPMs via the
# oebridge dnf flow (oe-xfce feature installs xfce4-* which brings gtk3/pango/
# cairo/X11/etc.) at image-assembly time. Yocto's file-rdeps resolves against
# Yocto package providers only and cannot see those dnf-provided RPMs, so it
# falsely flags them. The runtime deps are satisfied in the final image, so
# skip file-rdeps for this binary repack.
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped file-rdeps"

# SKIP_FILEDEPS: INSANE_SKIP only silences the QA check; the per-file (SONAME)
# auto-deps are still generated into the RPM as Requires(libX11.so.6()(64bit))...
# which then break do_rootfs (oe-repo has no providers -> "nothing provides").
# Disabling per-file dep generation removes those Requires so firefox-bin
# installs cleanly from oe-repo; the GUI libs arrive at runtime via the
# dnf-installed xfce4-* RPMs. Safe here: firefox's internal .so's (libxul etc.)
# are self-contained in the package and not required by anything external.
SKIP_FILEDEPS = "1"

ASSUME_PROVIDE_PKGS = "firefox"
