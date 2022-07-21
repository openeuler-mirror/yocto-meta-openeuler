# main bbfile: yocto-poky/meta/recipes-support/debianutils/debianutils_4.11.2.bb

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        http://snapshot.debian.org/archive/debian/20200929T025235Z/pool/main/d/${BPN}/${BPN}_${PV}.tar.xz \
"

# get extra tarball locally, because there is no debianutils src repository
FILESEXTRAPATHS_append := "${THISDIR}/files/:"
SRC_URI += " \
        file://${BPN}_${PV}.tar.xz \
"
