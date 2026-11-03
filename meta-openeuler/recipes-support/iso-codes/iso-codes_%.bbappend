# the main bb file: yocto-poky/meta/recipes-support/iso-codes/iso-codes_4.13.0.bb

PV = "4.20.1"

SRC_URI = "file://${BPN}-v${PV}.tar.bz2 \
"

S = "${WORKDIR}/${BPN}-v${PV}"

SRC_URI[sha256sum] = "66ea9879f9a4d6f767f424bf74bc5471215d36d54f8940f6d32dd7737ceef046"

BBCLASSEXTEND += "native"

# 4.20.1 switched to SPDX LICENSES/ dir, COPYING no longer exists
LIC_FILES_CHKSUM = "file://LICENSES/FSFAP.txt;md5=232368338ef6dc99de71c2e05ff12176"

# 4.20.1 switched from autotools to meson
inherit meson
