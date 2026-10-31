# bbfile: yocto-poky/meta/recipes-extended/ed/ed_1.18.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=cca7f74ec83b7a9ce7ccd195aad471bd \
                    file://ed.h;endline=20;md5=14c3e5e76d024c936c3afd2f89e5686b \
                    file://main.c;endline=17;md5=77c78fd940b4995c22cc1ae128bf0462 \
                    "
PV = "1.22.6"
SRC_URI = "file://ed-${PV}.tar.lz"

SRC_URI[sha256sum] = "3f33b22135219c39c3c695f7b7171c2567d3e2a17c798c0a90607320cbb268f2"

ASSUME_PROVIDE_PKGS = "ed"
