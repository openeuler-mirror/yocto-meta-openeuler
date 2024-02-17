# main bbfile: meta-oe/recipes-multimedia/cdrkit/cdrkit_1.1.11.bb

# files, patches can't be applied in openeuler or conflict with openeuler
# patches apply fail: 0001-genisoimage-Add-missing-extern-definition.patch
SRC_URI:remove = " \
        file://0001-genisoimage-Add-missing-extern-definition.patch \
"

# files, patches that come from openeuler
# CDDA cdparanoia is an audio CDs tool, thus don't apply cdrkit-1.1.11-paranoiacdda.patch
# cdrkit-1.1.11-cmakewarn.patch requires that the minimum version of cmake is 2.8, current is 3.19.5
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://cdrkit-1.1.8-werror.patch \
           file://cdrkit-1.1.9-efi-boot.patch \
           file://cdrkit-1.1.9-no_mp3.patch \
           file://cdrkit-1.1.9-buffer_overflow.patch \
           file://cdrkit-1.1.10-build-fix.patch \
           file://cdrkit-1.1.11-manpagefix.patch \
           file://cdrkit-1.1.11-rootstat.patch \
           file://cdrkit-1.1.11-usalinst.patch \
           file://cdrkit-1.1.11-readsegfault.patch \
           file://cdrkit-1.1.11-format.patch \
           file://cdrkit-1.1.11-handler.patch \
           file://cdrkit-1.1.11-dvdman.patch \
           file://cdrkit-1.1.11-utf8.patch \
           file://cdrkit-1.1.11-memset.patch \
           file://cdrkit-1.1.11-ppc64le_elfheader.patch \
           file://cdrkit-1.1.11-werror_gcc5.patch \
           file://cdrkit-1.1.11-devname.patch \
           file://cdrkit-1.1.11-sysmacros.patch \
           file://cdrkit-1.1.11-gcc10.patch \
           file://cdrkit-1.1.11-sw.patch \
"

SRC_URI[md5sum] = "efe08e2f3ca478486037b053acd512e9"
SRC_URI[sha256sum] = "d1c030756ecc182defee9fe885638c1785d35a2c2a297b4604c0e0dcc78e47da"

# fix problem "do_populate_sysroot: sstate found an absolute path symlink"
do_install:append() {
    rm -f ${D}${bindir}/mkisofs
    ln -sf --relative ${D}${bindir}/genisoimage ${D}${bindir}/mkisofs
}
