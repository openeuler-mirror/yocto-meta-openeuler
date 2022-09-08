# we use openeuler's config files

FILESEXTRAPATHS_append := "${THISDIR}/files/:"

SRC_URI += " \
        file://populate-openeuler-volatile.sh \
        file://openeuler-safety-volatiles \
        "

do_install_append() {
    install -d ${D}${sysconfdir}/default/openeuler-volatiles
    install -m 0644    ${WORKDIR}/openeuler-safety-volatiles     ${D}${sysconfdir}/default/openeuler-volatiles/00_core
    install -m 0755    ${WORKDIR}/populate-openeuler-volatile.sh ${D}${sysconfdir}/init.d
    #advice a low priority (99) to make it start later than any service and populate-volatile.sh
    update-rc.d -r ${D} populate-openeuler-volatile.sh start 99 S .
}

MASKED_SCRIPTS_append += " \
        populate-openeuler-volatile \
        "

pkg_postinst_${PN}_append () {
    # Delete any old volatile cache script, as directories may have moved
    if [ -z "$D" ]; then
        rm -f "/etc/openeuler-volatile.cache"
    fi
}
