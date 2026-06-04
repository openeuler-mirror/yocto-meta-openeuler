# bbfile: yocto-poky/meta/recipes-extended/ed/ed_1.18.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=76d6e300ffd8fb9d18bd9b136a9bba13 \
                    file://ed.h;endline=20;md5=504a90a78b045972e2fd2f3fc418c195 \
                    file://main.c;endline=17;md5=cf9d322b0ac4445ca2299c61ee175365 \
                    "
PV = "1.19"
SRC_URI = "file://ed-${PV}.tar.lz"

SRC_URI[sha256sum] = "ce2f2e5c424790aa96d09dacb93d9bbfdc0b7eb6249c9cb7538452e8ec77cd48"

ASSUME_PROVIDE_PKGS = "ed"
