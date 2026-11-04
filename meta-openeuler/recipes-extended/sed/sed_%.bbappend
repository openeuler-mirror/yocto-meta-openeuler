# main bbfile: yocto-poky/meta/recipes-extended/sed/sed_4.8.bb

PV = "4.10"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://sed/sed.h;beginline=1;endline=15;md5=3baf8c344ffa6281a98c30294ac62a6c \
"

# patches in openeuler (renamed in the src repo for 4.10)
SRC_URI += " \
    file://${BP}.tar.xz \
    file://sed-b-flag.patch \
    file://sed-c-flag.patch \
"

# note: libtool script need /usr/bin/sed, not /bin/sed, so we need to create a symlink
do_install:append() {
    install -d ${D}${bindir}
    cd ${D}${bindir}
    ln -sf ${base_bindir}/sed sed
}

ASSUME_PROVIDE_PKGS = "sed"