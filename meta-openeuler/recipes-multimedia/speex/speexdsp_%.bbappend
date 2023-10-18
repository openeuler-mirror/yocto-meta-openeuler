# main bb: yocto-poky/meta/recipes-multimedia/speex/speexdsp_1.2.0.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

LIC_FILES_CHKSUM = "file://COPYING;md5=eff3f76350f52a99a3df5eec6b79c02a"

PV = "1.2.1"

SRC_URI += " \
        file://speexdsp-${PV}.tar.gz \
"

S = "${WORKDIR}/speexdsp-${PV}"

