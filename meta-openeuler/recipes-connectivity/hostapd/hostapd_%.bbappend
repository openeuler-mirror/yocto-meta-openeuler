# main bb: yocto-meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.10.bb

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "2.10"

S = "${WORKDIR}/${BP}"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/hostapd/${BP}.tar.gz \
"

do_configure:append() {
    echo 'CONFIG_ACS=y' >> ${S}/hostapd/.config
}
