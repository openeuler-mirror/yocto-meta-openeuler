# main bbfile: yocto-poky/meta/recipes-extended/sed/sed_4.8.bb

PV = "4.9"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://sed/sed.h;beginline=1;endline=15;md5=4e8e0f77bc4c1c2c02c2b90d3d24c670 \
"

# patches in openeuler
SRC_URI += " \
    file://${BP}.tar.xz \
    file://sed/backport-sed-c-flag.patch \
"
