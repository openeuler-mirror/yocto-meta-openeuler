# main bbfile: yocto-poky/meta/recipes-support/libassuan/libassuan_2.5.5.bb

PV = "2.5.6"

# add patch from poky to fix gpgme configure error: cannot find libassuan
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI:prepend = "\
        file://${BP}.tar.bz2 \
        file://backport-libassuan-2.5.2-multilib.patch \
        file://backport-tests-Avoid-leaking-file-descriptors-on-errors.patch \
"
