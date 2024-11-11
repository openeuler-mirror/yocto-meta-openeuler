# main bb: yocto-meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.10.bb

inherit oee-archive

PV = "2.10"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += " \
        file://${BP}.tar.gz \
"
