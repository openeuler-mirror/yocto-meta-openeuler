# main bb: yocto-meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.10.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "2.10"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/hostapd/hostapd-${PV}.tar.gz \
"

S = "${WORKDIR}/hostapd-${PV}"

