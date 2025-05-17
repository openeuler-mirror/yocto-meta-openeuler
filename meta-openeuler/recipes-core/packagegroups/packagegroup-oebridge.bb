SUMMARY = "packagegroup of oebridge"

PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

PACKAGES = "${PN}"

# need glibc-external-utils provides binary such as locale, getent, etc.
RDEPENDS:${PN} = " \
    glibc-external-utils \
    libgpg-error \
    gpgme \
    libgcrypt \
"

# will call dnf to install INSTALL_PKG_LISTS's pkgs when do_rootfs
# the :force tag will force to install by using rpm -ivh and cover the pkg whatever oee do.
# note that:
#    do not add oee's rpm and dnf(it depends on python3),
#    we should use oe2403's python modules due to python3 version diffs.
INSTALL_PKG_LISTS = " \
    libsigsegv \
    libev \
    info \
    chkconfig \
    kbd-legacy \
    kbd-misc \
    keyutils-libs \
    libutempter \
    libverto \
    man-db \
    newt \
    slang \
    kpartx \
    openssl-pkcs11 \
    crypto-policies \
    dracut \
    krb5-libs \
    libkcapi \
    os-prober \
    grubby \
    dnf \
    rpm \
"

# we should ensure libstdc++ api is compatible, ohterwise we need oe's libstdc++.
# currently, oee's python3 is diff from oe2403, shoud use oe2403's pkg.
# other libs is incompatible with config, use oe's pkg, list is:
INSTALL_PKG_LISTS += " \
    python3:force \
    libgomp:force \
    libvorbis:force \
    libogg:force \
    ncurses-libs:force \
    libsndfile:force \
    libsamplerate:force \
    flac:force \
    glib2:force \
    avahi-libs:force \
    gobject-introspection:force \
"

python() {
    import os
    import subprocess

    # write INSTALL_PKG_LISTS to a file for getting install pkg list when do_rootfs
    with open(f"{d.getVar('TOPDIR')}/cache/INSTALL_PKG_LIST", 'w', encoding='utf-8') as f:
        f.write(d.getVar('INSTALL_PKG_LISTS').replace(" ", "\n"))

    d.setVar("ASSUME_PROVIDE_PKGS", d.getVar('INSTALL_PKG_LISTS'))
}
